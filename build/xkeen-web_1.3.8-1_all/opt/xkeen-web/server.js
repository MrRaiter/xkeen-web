#!/usr/bin/env node

const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { exec } = require('child_process');
const util = require('util');

const execPromiseRaw = util.promisify(exec);

// Exec with timeout (default 30 seconds)
function execPromise(cmd, timeoutMs = 30000) {
  return execPromiseRaw(cmd, { timeout: timeoutMs, killSignal: 'SIGKILL' });
}

// Configuration
const PORT = process.env.PORT || 91;
const CONFIG_DIR = process.env.XKEEN_CONFIG || '/opt/etc/xray/configs';
const SERVICE_NAME = 'xkeen';
// Use xkeen command directly with full path (init.d script may hang)
const SERVICE_CMD = process.env.XKEEN_SERVICE || '/opt/sbin/xkeen';

// Authentication
const AUTH_USER = process.env.XKEEN_USER || 'root';
const AUTH_PASS = process.env.XKEEN_PASS || 'keenetic';

// Session management (simple in-memory store)
const sessions = new Map();
const SESSION_TIMEOUT = 3600000; // 1 hour

// Generate session ID
function generateSessionId() {
  return crypto.randomBytes(32).toString('hex');
}

// Verify session
function verifySession(sessionId) {
  const session = sessions.get(sessionId);
  if (!session) return false;

  if (Date.now() - session.timestamp > SESSION_TIMEOUT) {
    sessions.delete(sessionId);
    return false;
  }

  session.timestamp = Date.now();
  return true;
}

// Parse cookies
function parseCookies(cookieHeader) {
  const cookies = {};
  if (!cookieHeader) return cookies;

  cookieHeader.split(';').forEach(cookie => {
    const [name, value] = cookie.trim().split('=');
    cookies[name] = value;
  });

  return cookies;
}

// Parse POST body
function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => body += chunk.toString());
    req.on('end', () => {
      try {
        const params = new URLSearchParams(body);
        const data = {};
        for (const [key, value] of params) {
          data[key] = value;
        }
        resolve(data);
      } catch (e) {
        reject(e);
      }
    });
  });
}

// Get list of config files
async function getFiles() {
  try {
    const files = await fs.promises.readdir(CONFIG_DIR);
    return files
      .filter(f => {
        // Include config files: .json, .conf, .list, .log, or files without extension (like 01_log, 03_inbounds)
        const hasExt = f.includes('.');
        if (!hasExt) return true; // Files without extension (Xray style)
        return f.endsWith('.json') || f.endsWith('.conf') || f.endsWith('.list') || f.endsWith('.log');
      })
      .sort((a, b) => {
        // Sort by type, then alphabetically
        const getPriority = (name) => {
          if (name.endsWith('.json') || !name.includes('.')) return 0;
          if (name.endsWith('.conf')) return 1;
          if (name.endsWith('.list')) return 2;
          return 3;
        };
        return getPriority(a) - getPriority(b) || a.localeCompare(b);
      });
  } catch (e) {
    return [];
  }
}

// Get file content
async function getFileContent(filename) {
  const filepath = path.join(CONFIG_DIR, path.basename(filename));
  try {
    const content = await fs.promises.readFile(filepath, 'utf-8');
    return { content };
  } catch (e) {
    return { content: '', error: e.message };
  }
}

// Save file content
async function saveFile(filename, content) {
  const filepath = path.join(CONFIG_DIR, path.basename(filename));
  try {
    await fs.promises.writeFile(filepath, content, 'utf-8');
    return { success: true };
  } catch (e) {
    return { error: e.message };
  }
}

// Remove file
async function removeFile(filename) {
  const filepath = path.join(CONFIG_DIR, path.basename(filename));
  try {
    await fs.promises.unlink(filepath);
    return { success: true };
  } catch (e) {
    return { error: e.message };
  }
}

// Check service status
async function getServiceStatus() {
  try {
    // Check if xray process is running
    const { stdout: psOutput } = await execPromise('ps | grep -v grep | grep xray || true');
    return psOutput.trim().length > 0;
  } catch (e) {
    return false;
  }
}

// Strip ANSI escape codes from text
function stripAnsi(text) {
  return text.replace(/\x1B\[[0-9;]*[a-zA-Z]/g, '').replace(/\[[\d;]*m/g, '');
}

// Service action
async function serviceAction(action) {
  const allowedActions = ['start', 'stop', 'restart', 'status'];
  if (!allowedActions.includes(action)) {
    return { error: 'Invalid action' };
  }

  // xkeen uses -flag format: xkeen -start, xkeen -stop, etc.
  const cmd = `${SERVICE_CMD} -${action}`;
  console.log('Executing command:', cmd);

  try {
    const { stdout, stderr } = await execPromise(cmd + ' 2>&1');
    let output = [stdout, stderr].filter(Boolean).map(stripAnsi).filter(s => s.trim());

    // If no output, provide a default message
    if (output.length === 0 || output.every(s => !s.trim())) {
      const messages = {
        start: 'Service started successfully',
        stop: 'Service stopped successfully',
        restart: 'Service restarted successfully',
        status: 'Status check completed'
      };
      output = [messages[action] || 'Done'];
    }

    return { output };
  } catch (e) {
    // When command fails, capture stdout/stderr from error object
    const errorOutput = [];
    if (e.stdout) errorOutput.push(stripAnsi(e.stdout));
    if (e.stderr) errorOutput.push(stripAnsi(e.stderr));
    if (errorOutput.length === 0) {
      errorOutput.push(`Failed to ${action} service: ${e.message}`);
    }
    return { status: e.code || 1, output: errorOutput.filter(s => s.trim()) };
  }
}

// Upgrade service
async function upgradeService() {
  try {
    const commands = [
      'opkg update',
      'opkg upgrade xkeen'
    ].join(' && ');

    const { stdout, stderr } = await execPromise(commands);
    return { output: [stdout, stderr].filter(Boolean) };
  } catch (e) {
    return { status: e.code || 1, output: [e.message] };
  }
}

// Get version
function getVersion() {
  try {
    const versionFile = path.join(__dirname, 'VERSION');
    if (fs.existsSync(versionFile)) {
      return fs.readFileSync(versionFile, 'utf-8').trim();
    }
  } catch (e) {
    // ignore
  }
  return '1.0.0';
}

// Request handler
async function handleRequest(req, res) {
  const url = new URL(req.url, `http://${req.headers.host}`);

  // CORS headers (optional, for development)
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST');

  // Parse cookies
  const cookies = parseCookies(req.headers.cookie);
  const sessionId = cookies.session;

  // Debug logging
  console.log(`[${req.method}] ${url.pathname} - Cookie: ${sessionId ? sessionId.substring(0, 8) + '...' : 'none'} - Sessions: ${sessions.size}`);

  // Check if authenticated (except for login and static files)
  const isAuthenticated = sessionId && verifySession(sessionId);
  console.log(`Auth check: sessionId=${!!sessionId}, verified=${isAuthenticated}`);

  if (req.method === 'POST' && url.pathname === '/api') {
    try {
      const data = await parseBody(req);

      // Login endpoint
      if (data.cmd === 'login') {
        console.log(`Login attempt: user=${data.user}, expected=${AUTH_USER}`);
        if (data.user === AUTH_USER && data.password === AUTH_PASS) {
          const newSessionId = generateSessionId();
          sessions.set(newSessionId, { timestamp: Date.now() });
          console.log(`Login success! New session: ${newSessionId.substring(0, 8)}... Total sessions: ${sessions.size}`);

          res.writeHead(200, {
            'Content-Type': 'application/json',
            'Set-Cookie': `session=${newSessionId}; Path=/; HttpOnly; SameSite=Lax; Max-Age=3600`
          });
          res.end(JSON.stringify({ status: 0 }));
          return;
        } else {
          res.writeHead(200, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ status: 1, error: 'Invalid credentials' }));
          return;
        }
      }

      // Logout endpoint
      if (data.cmd === 'logout') {
        if (sessionId) {
          sessions.delete(sessionId);
        }
        res.writeHead(200, {
          'Content-Type': 'application/json',
          'Set-Cookie': 'session=; Path=/; HttpOnly; Max-Age=0'
        });
        res.end(JSON.stringify({ status: 0 }));
        return;
      }

      // Check authentication for other endpoints
      if (!isAuthenticated) {
        res.writeHead(401, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ status: 401, error: 'Unauthorized' }));
        return;
      }

      // Handle commands
      let response = {};

      switch (data.cmd) {
        case 'filenames':
          const files = await getFiles();
          const service = await getServiceStatus();
          response = { files, service };
          break;

        case 'filecontent':
          response = await getFileContent(data.filename);
          break;

        case 'filesave':
          response = await saveFile(data.filename, data.content || '');
          break;

        case 'fileremove':
          response = await removeFile(data.filename);
          break;

        case 'start':
        case 'stop':
        case 'restart':
        case 'reload':
        case 'status':
          response = await serviceAction(data.cmd);
          break;

        case 'upgrade':
          response = await upgradeService();
          break;

        default:
          response = { error: 'Unknown command' };
      }

      res.writeHead(200, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify(response));

    } catch (e) {
      res.writeHead(500, { 'Content-Type': 'application/json' });
      res.end(JSON.stringify({ error: e.message }));
    }
    return;
  }

  // Serve static files
  if (req.method === 'GET') {
    // Require auth for main page
    if (url.pathname === '/' || url.pathname === '/index.html') {
      if (!isAuthenticated) {
        // Serve login page
        const loginPage = fs.readFileSync(path.join(__dirname, 'public', 'index.html'), 'utf-8')
          .replace('__VERSION__', getVersion())
          .replace('__AUTHENTICATED__', 'false');

        res.writeHead(200, {
          'Content-Type': 'text/html',
          'Cache-Control': 'no-store, no-cache, must-revalidate',
          'Pragma': 'no-cache',
          'Expires': '0'
        });
        res.end(loginPage);
        return;
      }

      const indexPage = fs.readFileSync(path.join(__dirname, 'public', 'index.html'), 'utf-8')
        .replace('__VERSION__', getVersion())
        .replace('__AUTHENTICATED__', 'true');

      res.writeHead(200, {
        'Content-Type': 'text/html',
        'Cache-Control': 'no-store, no-cache, must-revalidate',
        'Pragma': 'no-cache',
        'Expires': '0'
      });
      res.end(indexPage);
      return;
    }

    // Serve favicon
    if (url.pathname === '/favicon.ico') {
      res.writeHead(404);
      res.end();
      return;
    }
  }

  // 404
  res.writeHead(404);
  res.end('Not Found');
}

// Create server
const server = http.createServer(handleRequest);

server.listen(PORT, () => {
  console.log(`xkeen-web-ui server running on http://0.0.0.0:${PORT}`);
  console.log(`Config directory: ${CONFIG_DIR}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
