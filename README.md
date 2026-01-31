# xkeen-web-ui

Lightweight web UI for xkeen configuration management, built with pure Node.js (zero dependencies).

## Features

- 🔐 **Basic Authentication** - Secure login with username/password
- 📝 **Config Editor** - Edit configuration files with syntax highlighting
- 🔄 **Service Control** - Start, stop, restart, and reload xkeen service
- 📁 **Multi-file Support** - Manage multiple config files with tabs
- 🌓 **Dark/Light Theme** - Toggle between themes
- 💾 **Auto-save Detection** - Visual indicator for unsaved changes
- 📊 **Service Status** - Real-time service status indicator
- 🚀 **Minimal Bundle** - ~20KB total (HTML + CSS + JS inline)

## Installation

### Prerequisites

- Node.js >= 14.0.0
- XKeen installed on your system (optional, for service control)
- Keenetic router with Entware or OpenWrt-compatible system

### Method 1: Install via opkg (Recommended)

**From custom repository (once published):**

```bash
# Add repository (if needed)
echo "src/gz xkeen-web-ui https://your-repo-url/packages" > /opt/etc/opkg/xkeen-web-ui.conf

# Install
opkg update
opkg install xkeen-web-ui
```

**From downloaded .ipk file:**

```bash
# Download the package
cd /tmp
wget https://your-repo-url/xkeen-web-ui_1.0.0-1_all.ipk

# Install
opkg install xkeen-web-ui_1.0.0-1_all.ipk
```

**From local build:**

```bash
# Build the package (on development machine)
chmod +x build-opkg.sh
./build-opkg.sh

# Copy to router
scp build/xkeen-web-ui_1.0.0-1_all.ipk root@192.168.1.1:/tmp/

# SSH to router and install
ssh root@192.168.1.1
opkg install /tmp/xkeen-web-ui_1.0.0-1_all.ipk
```

After installation:

```bash
# Start the service
/opt/etc/init.d/S90xkeen-web-ui start

# Service starts automatically on boot
```

Access the web UI at: **http://192.168.1.1:91**

**Note:** Port 91 is used by default (port 90 is typically reserved for nfqws-keenetic-web)

Default credentials:
- Username: `root`
- Password: `keenetic`

### Method 2: Manual Installation

1. Clone or download this repository:

```bash
cd /tmp
git clone <your-repo-url> xkeen-web-ui
cd xkeen-web-ui

# Or download and extract
wget https://github.com/yourusername/xkeen-web-ui/archive/main.tar.gz
tar xzf main.tar.gz
cd xkeen-web-ui-main
```

2. Run the installation script:

```bash
chmod +x install-manual.sh
./install-manual.sh
```

3. The script will:
   - Copy files to `/opt/xkeen-web-ui`
   - Install init.d script
   - Create configuration file
   - Optionally start the service

### Method 3: Development Mode

For development or testing:

```bash
# Configure environment variables (optional)
export PORT=91
export XKEEN_CONFIG=/opt/etc/xkeen
export XKEEN_SERVICE=/opt/etc/init.d/S24xray
export XKEEN_USER=admin
export XKEEN_PASS=yourpassword

# Start directly
node server.js
```

Access at: **http://192.168.1.1:91**

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `91` | Port for web server (90 is for nfqws) |
| `XKEEN_CONFIG` | `/opt/etc/xkeen` | Path to xkeen config directory |
| `XKEEN_SERVICE` | `/opt/etc/init.d/S51xkeen` | Path to xkeen service script |
| `XKEEN_USER` | `root` | Authentication username |
| `XKEEN_PASS` | `keenetic` | Authentication password |

### File Structure

```
xkeen-web-ui/
├── server.js          # Node.js HTTP server
├── public/
│   └── index.html     # Single-page app (HTML + CSS + JS)
├── package.json       # Package metadata
├── VERSION            # Version file
└── README.md          # This file
```

## Usage

### Editing Configuration Files

1. Log in with your credentials
2. Select a file from the tabs at the top
3. Edit the content in the textarea
4. Click "Save" or press `Ctrl+S` (or `Cmd+S` on Mac)

### Service Control

Click the "Menu" button in the header to access:
- **Restart Service** - Restart xkeen
- **Reload Service** - Reload configuration without stopping
- **Start Service** - Start xkeen if stopped
- **Stop Service** - Stop xkeen

### Theme Toggle

Switch between dark and light themes via the Menu dropdown.

## Development

This project uses **zero external dependencies** - only Node.js built-in modules:
- `http` - Web server
- `fs` - File system operations
- `path` - Path utilities
- `crypto` - Session ID generation
- `child_process` - Service control

### Running in Development

```bash
npm run dev
```

### Customization

All HTML, CSS, and JavaScript are in a single file (`public/index.html`) for easy customization and minimal bundle size.

## Security

- Sessions are stored in-memory with 1-hour timeout
- HttpOnly cookies prevent XSS attacks
- Basic authentication with configurable credentials
- File operations are restricted to config directory
- Service commands are whitelisted

**Important:** Change default credentials in production!

```bash
export XKEEN_USER=yourusername
export XKEEN_PASS=yourpassword
```

## Auto-start on Boot

### systemd (Linux)

Create `/etc/systemd/system/xkeen-web-ui.service`:

```ini
[Unit]
Description=xkeen Web UI
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/xkeen-web-ui
Environment="PORT=91"
Environment="XKEEN_USER=admin"
Environment="XKEEN_PASS=yourpassword"
ExecStart=/usr/bin/node /opt/xkeen-web-ui/server.js
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
systemctl enable xkeen-web-ui
systemctl start xkeen-web-ui
```

### init.d (Entware)

Create `/opt/etc/init.d/S90xkeen-web-ui`:

```bash
#!/bin/sh

ENABLED=yes
PROCS=server.js
ARGS=""
PREARGS=""
DESC="xkeen Web UI"
PATH=/opt/sbin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

. /opt/etc/init.d/rc.func
```

Make executable and start:

```bash
chmod +x /opt/etc/init.d/S90xkeen-web-ui
/opt/etc/init.d/S90xkeen-web-ui start
```

## opkg Package Management

### Install

```bash
opkg install xkeen-web-ui
```

### Upgrade

```bash
opkg update
opkg upgrade xkeen-web-ui
```

### Remove

```bash
# Remove package (keeps config)
opkg remove xkeen-web-ui

# Remove with config
opkg remove --force-removal-of-dependent-packages xkeen-web-ui
rm -rf /opt/etc/xkeen-web-ui
```

### Check Version

```bash
opkg info xkeen-web-ui
```

### List Files

```bash
opkg files xkeen-web-ui
```

## Service Management

After installation via opkg, the service is controlled via init.d:

```bash
# Start service
/opt/etc/init.d/S90xkeen-web-ui start

# Stop service
/opt/etc/init.d/S90xkeen-web-ui stop

# Restart service
/opt/etc/init.d/S90xkeen-web-ui restart

# Check status
/opt/etc/init.d/S90xkeen-web-ui status

# Check if running
ps | grep server.js
```

The service starts automatically on boot (via S90 init.d script).

## Troubleshooting

### Server won't start

Check if port 91 is already in use:

```bash
netstat -tlnp | grep :91
```

Use a different port:

```bash
PORT=8091 node server.js
```

### Cannot access from other devices

Make sure your firewall allows connections on port 91:

```bash
iptables -I INPUT -p tcp --dport 91 -j ACCEPT
```

### Service commands don't work

Verify the service script path:

```bash
ls -l /opt/etc/init.d/S51xkeen
```

Set correct path:

```bash
export XKEEN_SERVICE=/path/to/your/service/script
```

## Comparison with nfqws-keenetic-web

| Feature | xkeen-web-ui | nfqws-keenetic-web |
|---------|--------------|-------------------|
| Backend | Pure Node.js | PHP + Lighttpd |
| Dependencies | 0 | php-cgi, lighttpd |
| Bundle Size | ~20KB | ~50KB+ |
| Memory Usage | ~15MB | ~30MB+ |
| Authentication | Built-in | HTTP Basic Auth |
| Dark Theme | Yes | Yes |

## License

MIT

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## Credits

Inspired by [nfqws-keenetic-web](https://github.com/Anonym-tsk/nfqws-keenetic) by Anonym-tsk.
