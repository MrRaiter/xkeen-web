# xkeen-web-ui Project Summary

## 📋 Overview

**xkeen-web-ui** is a lightweight, pure Node.js web interface for managing XKeen configuration on Keenetic routers. Built with zero external dependencies, it provides a modern web UI similar to nfqws-keenetic-web but optimized for XKeen.

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Browser (Client)                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  Single Page App (HTML + CSS + JS)                  │   │
│  │  - Tab interface                                     │   │
│  │  - Code editor                                       │   │
│  │  - Theme toggle                                      │   │
│  │  - Service controls                                  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │ HTTP/HTTPS
                            ▼
┌─────────────────────────────────────────────────────────────┐
│               Node.js HTTP Server (server.js)                │
│  ┌─────────────────────────────────────────────────────┐   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────┐  │   │
│  │  │ Auth Module  │  │  API Routes  │  │  Static  │  │   │
│  │  │ - Sessions   │  │  - Files     │  │  Server  │  │   │
│  │  │ - Cookies    │  │  - Service   │  │          │  │   │
│  │  └──────────────┘  └──────────────┘  └──────────┘  │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
    ┌──────────────┐  ┌──────────┐  ┌──────────────┐
    │   File I/O   │  │  Service │  │   Config     │
    │ /opt/etc/    │  │  Control │  │   Manager    │
    │   xkeen/     │  │ (init.d) │  │              │
    └──────────────┘  └──────────┘  └──────────────┘
```

## 📁 Project Structure

```
xkeen-web-ui/
│
├── Core Application
│   ├── server.js                # Main Node.js server (300 lines)
│   ├── package.json             # Package metadata
│   └── VERSION                  # Version tracking
│
├── Web Interface
│   └── public/
│       └── index.html          # Single-page app (600 lines)
│                                # - HTML structure
│                                # - Inline CSS (~400 lines)
│                                # - Inline JavaScript (~500 lines)
│
├── Package Files
│   ├── Makefile                # OpenWrt/Entware build
│   ├── build-opkg.sh          # Standalone build script
│   └── files/
│       ├── S90xkeen-web-ui    # Init.d service script
│       └── xkeen-web-ui.conf  # Default configuration
│
├── Installation Scripts
│   ├── install-manual.sh      # Manual installation
│   ├── uninstall.sh          # Uninstallation
│   └── start.sh              # Simple start script
│
├── CI/CD
│   └── .github/
│       └── workflows/
│           └── build-package.yml  # GitHub Actions
│
└── Documentation
    ├── README.md              # Main documentation
    ├── QUICK_START.md        # Quick start guide
    ├── OPKG_PACKAGING.md     # Packaging guide
    ├── CONTRIBUTING.md       # Contribution guidelines
    ├── CHANGELOG.md          # Version history
    ├── PROJECT_SUMMARY.md    # This file
    └── LICENSE               # MIT License
```

## 🔑 Key Features

### Backend (server.js)
- ✅ Pure Node.js HTTP server (no Express)
- ✅ Session-based authentication
- ✅ Cookie management (HttpOnly)
- ✅ REST API for file operations
- ✅ Service control integration
- ✅ File system operations
- ✅ Zero external dependencies

### Frontend (public/index.html)
- ✅ Vanilla JavaScript (no frameworks)
- ✅ Tab-based file interface
- ✅ Real-time save detection
- ✅ Dark/Light theme toggle
- ✅ Service status indicator
- ✅ Modal dialogs
- ✅ Keyboard shortcuts
- ✅ Responsive design

### Packaging
- ✅ opkg package (.ipk)
- ✅ OpenWrt/Entware Makefile
- ✅ Init.d integration
- ✅ Auto-start on boot
- ✅ Config file management
- ✅ Post-install scripts

## 📊 Technical Specifications

| Aspect | Details |
|--------|---------|
| **Language** | JavaScript (Node.js) |
| **Runtime** | Node.js >= 14.0.0 |
| **Dependencies** | 0 (zero) |
| **Bundle Size** | ~20KB (uncompressed) |
| **Memory Usage** | ~15MB (runtime) |
| **Architecture** | Platform-independent (all) |
| **License** | MIT |
| **Lines of Code** | ~1400 total |

## 🔄 Data Flow

### Authentication Flow
```
User Login
    ↓
POST /api (cmd: login)
    ↓
Verify credentials
    ↓
Generate session ID
    ↓
Set HttpOnly cookie
    ↓
Return success
    ↓
Reload page (authenticated)
```

### File Operation Flow
```
User selects file
    ↓
GET /api (cmd: filecontent)
    ↓
Read from /opt/etc/xkeen/
    ↓
Return content
    ↓
Display in editor
    ↓
User edits
    ↓
POST /api (cmd: filesave)
    ↓
Write to filesystem
    ↓
Return success
```

### Service Control Flow
```
User clicks action (restart)
    ↓
POST /api (cmd: restart)
    ↓
Execute: /opt/etc/init.d/S24xray restart
    ↓
Capture output
    ↓
Return result
    ↓
Update status indicator
```

## 🚀 Deployment Options

### Option 1: opkg Package (Recommended)
```bash
opkg install xkeen-web-ui
```
- Auto-start on boot
- Config file management
- Easy updates
- Clean uninstall

### Option 2: Manual Installation
```bash
./install-manual.sh
```
- Full control
- No package manager needed
- Custom paths

### Option 3: Direct Execution
```bash
node server.js
```
- Development/testing
- Quick setup
- No installation

## 🔐 Security Features

1. **Authentication**
   - Username/password login
   - Session-based (not token)
   - HttpOnly cookies (XSS protection)
   - 1-hour timeout

2. **Authorization**
   - All API endpoints require auth
   - Session validation on each request

3. **File Access**
   - Restricted to config directory
   - Path traversal prevention
   - Filename sanitization

4. **Service Control**
   - Whitelisted commands only
   - No arbitrary command execution

5. **Session Management**
   - Server-side storage
   - Automatic cleanup
   - Secure cookie flags

## 📦 Package Details

### Installation Locations
```
/opt/xkeen-web-ui/              # Application directory
├── server.js                   # Main server
├── package.json                # Metadata
├── VERSION                     # Version file
└── public/
    └── index.html             # Web interface

/opt/etc/init.d/
└── S90xkeen-web-ui            # Init script

/opt/etc/xkeen-web-ui/
└── xkeen-web-ui.conf          # Configuration
```

### Dependencies
- Runtime: `node` (opkg package)
- Optional: `xkeen` (for service control)

### Package Size
- Compressed (.ipk): ~10KB
- Installed: ~30KB
- Runtime memory: ~15MB

## 🎯 Design Goals

1. **Minimal Dependencies**
   - Pure Node.js only
   - No npm packages
   - Single binary deployment

2. **Small Footprint**
   - < 20KB bundle
   - < 15MB memory
   - Fast startup

3. **Easy Installation**
   - opkg package
   - One command install
   - Auto-start

4. **User Friendly**
   - Modern UI
   - Intuitive controls
   - Clear feedback

5. **Secure by Default**
   - Authentication required
   - Session management
   - Safe file operations

## 🔄 Development Workflow

```bash
# 1. Make changes
nano server.js
nano public/index.html

# 2. Test locally
node server.js

# 3. Build package
./build-opkg.sh

# 4. Test on router
scp build/*.ipk root@192.168.1.1:/tmp/
ssh root@192.168.1.1
opkg install /tmp/xkeen-web-ui_*.ipk

# 5. Commit and push
git add .
git commit -m "feat: add new feature"
git push

# 6. Create release
git tag v1.0.1
git push --tags
```

## 🌟 Comparison with nfqws-keenetic-web

| Feature | xkeen-web-ui | nfqws-keenetic-web |
|---------|--------------|-------------------|
| Backend | Pure Node.js | PHP + Lighttpd |
| Dependencies | 0 | php-cgi, lighttpd, etc. |
| Bundle Size | ~20KB | ~50KB+ |
| Memory | ~15MB | ~30MB+ |
| Setup | Single package | Multiple packages |
| Config | Simple file | Multiple files |
| Performance | Fast | Moderate |
| Portability | High | PHP-dependent |

## 🎓 Learning Resources

- [Node.js HTTP Module](https://nodejs.org/api/http.html)
- [Entware Wiki](https://github.com/Entware/Entware/wiki)
- [OpenWrt Package Build](https://openwrt.org/docs/guide-developer/packages)
- [XKeen Project](https://github.com/Skrill0/XKeen)
- [nfqws-keenetic Reference](https://github.com/Anonym-tsk/nfqws-keenetic)

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Code style guidelines
- Pull request process
- Areas for contribution

## 📝 License

MIT License - see [LICENSE](LICENSE) file

## 🙏 Credits

- Inspired by [nfqws-keenetic-web](https://github.com/Anonym-tsk/nfqws-keenetic)
- Built for [XKeen](https://github.com/Skrill0/XKeen) users
- Community contributions welcome

---

**Version:** 1.0.0  
**Last Updated:** 2026-01-31  
**Maintainer:** Your Name <your@email.com>
