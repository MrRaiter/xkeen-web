# opkg Packaging Guide for xkeen-web-ui

This guide explains how to build and publish the xkeen-web-ui opkg package.

## Package Structure

```
xkeen-web-ui/
├── build-opkg.sh              # Build script
├── Makefile                   # OpenWrt/Entware Makefile
├── files/
│   ├── S90xkeen-web-ui       # init.d service script
│   └── xkeen-web-ui.conf     # Default configuration
├── server.js                  # Main application
├── public/
│   └── index.html            # Web interface
├── package.json              # Package metadata
└── VERSION                    # Version file
```

## Building the Package

### Method 1: Using build-opkg.sh (Standalone)

This method creates a standalone .ipk package without needing the full OpenWrt/Entware build system.

```bash
# Make script executable
chmod +x build-opkg.sh

# Build package
./build-opkg.sh
```

Output: `build/xkeen-web-ui_1.0.0-1_all.ipk`

### Method 2: Using OpenWrt/Entware SDK

For official package repositories:

```bash
# Clone Entware
git clone https://github.com/Entware/Entware.git
cd Entware

# Copy package directory
cp -r /path/to/xkeen-web-ui package/xkeen-web-ui

# Build
make package/xkeen-web-ui/compile
```

## Package Contents

The built package installs:

- `/opt/xkeen-web-ui/` - Application directory
  - `server.js` - Node.js server
  - `package.json` - Package metadata
  - `VERSION` - Version file
  - `public/index.html` - Web interface

- `/opt/etc/init.d/S90xkeen-web-ui` - Init script for auto-start

- `/opt/etc/xkeen-web-ui/xkeen-web-ui.conf` - Configuration file

## Package Metadata

- **Package name:** `xkeen-web-ui`
- **Version:** 1.0.0
- **Architecture:** `all` (pure JavaScript, platform-independent)
- **Dependencies:** `node`
- **Recommended:** `xkeen` (for integration with XKeen)
- **Size:** ~30KB installed

## Installation Scripts

### postinst (Post-installation)

Runs after package installation:
- Sets executable permissions
- Creates config directories
- Displays installation success message

### prerm (Pre-removal)

Runs before package removal:
- Stops the running service

### postrm (Post-removal)

Runs after package removal:
- Displays removal message
- Notes that config files are preserved

## Configuration Files

The package marks `/opt/etc/xkeen-web-ui/xkeen-web-ui.conf` as a conffile, which means:
- Won't be overwritten on package upgrade
- Preserved when package is removed
- User modifications are kept

## Publishing to Repository

### Step 1: Build for All Architectures

Even though the package is architecture-independent (`all`), you may want to test on different systems:

```bash
./build-opkg.sh
```

### Step 2: Create Repository Structure

```
repo/
├── Packages          # Package index (generated)
├── Packages.gz       # Compressed index
└── xkeen-web-ui_1.0.0-1_all.ipk
```

### Step 3: Generate Package Index

```bash
cd repo/

# Create Packages file
opkg-make-index . > Packages

# Compress
gzip -c Packages > Packages.gz
```

### Step 4: Host the Repository

Upload to a web server (GitHub Pages, your own server, etc.):

```bash
# Example with GitHub Pages
git clone https://github.com/yourusername/xkeen-web-ui-repo.git
cd xkeen-web-ui-repo
mkdir -p packages
cp ../build/*.ipk packages/
cd packages
opkg-make-index . > Packages
gzip -c Packages > Packages.gz
cd ..
git add .
git commit -m "Add xkeen-web-ui package"
git push
```

### Step 5: User Installation

Users can now add your repository:

```bash
# On Keenetic router
echo "src/gz xkeen-web-ui https://yourusername.github.io/xkeen-web-ui-repo/packages" > /opt/etc/opkg/xkeen-web-ui.conf

opkg update
opkg install xkeen-web-ui
```

## Integration with XKeen Repository

To integrate with the official XKeen repository (if accepted):

1. Fork the XKeen repository
2. Add `xkeen-web-ui` package to the packages directory
3. Update package index
4. Submit pull request

## Version Management

Update version in:
- `VERSION` file
- `Makefile` (PKG_VERSION)
- `package.json` (version field)

Then rebuild:

```bash
./build-opkg.sh
```

## Testing the Package

Before publishing:

```bash
# Install on test router
opkg install /tmp/xkeen-web-ui_1.0.0-1_all.ipk

# Verify files
opkg files xkeen-web-ui

# Test service
/opt/etc/init.d/S90xkeen-web-ui start
ps | grep server.js

# Test web interface
curl http://192.168.1.1:91

# Check logs
logread | grep xkeen-web-ui

# Remove
opkg remove xkeen-web-ui
```

## Continuous Integration

Example GitHub Actions workflow:

```yaml
name: Build opkg package

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install -y binutils-multiarch
      
      - name: Build package
        run: |
          chmod +x build-opkg.sh
          ./build-opkg.sh
      
      - name: Upload artifact
        uses: actions/upload-artifact@v2
        with:
          name: xkeen-web-ui-package
          path: build/*.ipk
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: build/*.ipk
```

## Troubleshooting Package Build

### "ar: command not found"

Install binutils:
```bash
# Debian/Ubuntu
sudo apt-get install binutils

# Entware
opkg install binutils
```

### Permission errors

Ensure scripts are executable:
```bash
chmod +x build-opkg.sh
chmod +x files/S90xkeen-web-ui
```

### Package won't install

Check dependencies:
```bash
opkg update
opkg install node
```

## References

- [Entware Wiki](https://github.com/Entware/Entware/wiki)
- [OpenWrt Package Build](https://openwrt.org/docs/guide-developer/packages)
- [opkg Package Format](https://openwrt.org/docs/guide-user/additional-software/opkg)
- [nfqws-keenetic packaging](https://github.com/Anonym-tsk/nfqws-keenetic) (reference implementation)
