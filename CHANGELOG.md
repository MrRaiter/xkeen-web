# Changelog

All notable changes to xkeen-web-ui will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-31

### Added
- Initial release of xkeen-web-ui
- Pure Node.js HTTP server with zero external dependencies
- Web-based configuration editor for XKeen
- Multi-file tab interface for config management
- Session-based authentication system
- Service control (start, stop, restart, reload)
- Dark/Light theme toggle with persistence
- Real-time service status indicator
- Auto-save detection with visual feedback
- Log file viewing and clearing
- opkg package support for easy installation
- Init.d script for automatic startup
- Configuration file support
- Manual installation script
- GitHub Actions workflow for automated builds
- Comprehensive documentation

### Features
- **Authentication**: Username/password login with session management
- **Config Editor**: Edit .conf, .list, and .log files
- **Service Control**: Start/stop/restart XKeen/Xray service
- **File Management**: Save, load, and clear files
- **Theme Support**: Toggle between dark and light themes
- **Status Display**: Real-time service status with visual indicator
- **Keyboard Shortcuts**: Ctrl+S to save
- **Responsive Design**: Works on desktop and mobile browsers
- **Minimal Footprint**: ~20KB total bundle size
- **Zero Dependencies**: Pure Node.js, no npm packages required

### Installation Methods
- opkg package installation (.ipk)
- Manual installation script
- Direct Node.js execution for development

### Security
- HttpOnly session cookies
- 1-hour session timeout
- Password-protected endpoints
- File operations restricted to config directory
- Whitelisted service commands

### Compatibility
- Keenetic routers with Entware
- OpenWrt-based systems
- Node.js >= 14.0.0
- Works with XKeen/Xray installations

### Documentation
- README.md with installation instructions
- OPKG_PACKAGING.md for package building
- CONTRIBUTING.md for developers
- Inline code documentation

## [0.1.0] - 2026-01-31 (Development)

### Added
- Project structure setup
- Basic server implementation
- Web interface prototype

[Unreleased]: https://github.com/yourusername/xkeen-web-ui/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/yourusername/xkeen-web-ui/releases/tag/v1.0.0
[0.1.0]: https://github.com/yourusername/xkeen-web-ui/releases/tag/v0.1.0
