#!/bin/bash

# Build script for xkeen-web-ui opkg package
# This script creates an ipk package that can be installed via opkg

set -e

# Package information
PKG_NAME="xkeen-web"
PKG_VERSION=$(cat VERSION)
PKG_RELEASE="1"
PKG_ARCH="all"
MAINTAINER="Your Name <your@email.com>"

BUILD_DIR="build"
PKG_DIR="${BUILD_DIR}/${PKG_NAME}_${PKG_VERSION}-${PKG_RELEASE}_${PKG_ARCH}"

echo "Building ${PKG_NAME} version ${PKG_VERSION}-${PKG_RELEASE}..."

# Clean previous build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Create package directory structure
mkdir -p "${PKG_DIR}/opt/xkeen-web"
mkdir -p "${PKG_DIR}/opt/xkeen-web/public"
mkdir -p "${PKG_DIR}/opt/etc/init.d"
mkdir -p "${PKG_DIR}/opt/etc/xkeen-web"
mkdir -p "${PKG_DIR}/CONTROL"

# Copy application files
echo "Copying application files..."
cp server.js "${PKG_DIR}/opt/xkeen-web/"
cp package.json "${PKG_DIR}/opt/xkeen-web/"
cp VERSION "${PKG_DIR}/opt/xkeen-web/"
cp public/index.html "${PKG_DIR}/opt/xkeen-web/public/"

# Copy init.d script
cp files/S90xkeen-web "${PKG_DIR}/opt/etc/init.d/"
chmod +x "${PKG_DIR}/opt/etc/init.d/S90xkeen-web"

# Copy config file
cp files/xkeen-web.conf "${PKG_DIR}/opt/etc/xkeen-web/"

# Make server.js executable
chmod +x "${PKG_DIR}/opt/xkeen-web/server.js"

# Create control file
echo "Creating control file..."
cat > "${PKG_DIR}/CONTROL/control" <<EOF
Package: ${PKG_NAME}
Version: ${PKG_VERSION}-${PKG_RELEASE}
Architecture: ${PKG_ARCH}
Maintainer: ${MAINTAINER}
Section: net
Priority: optional
Homepage: https://github.com/yourusername/xkeen-web
Depends: node
Description: Web UI for XKeen/Xray configuration management
 Lightweight web interface for XKeen/Xray configuration management.
 Built with pure Node.js (zero dependencies).
 Features: config editor, service control, authentication, dark/light theme.
 Access via http://router-ip:91
EOF

# Create postinst script
cat > "${PKG_DIR}/CONTROL/postinst" <<'EOF'
#!/bin/sh
set -e

echo "Configuring xkeen-web..."

# Set executable permissions
chmod +x /opt/xkeen-web/server.js
chmod +x /opt/etc/init.d/S90xkeen-web

# Create config directory if not exists
[ -d /opt/etc/xray/configs ] || mkdir -p /opt/etc/xray/configs

echo ""
echo "================================================"
echo "xkeen-web installed successfully!"
echo "================================================"
echo ""
echo "Access: http://192.168.1.1:91"
echo "Note: Port 91 is used (port 90 is for nfqws-keenetic-web)"
echo "Default credentials:"
echo "  Username: root"
echo "  Password: keenetic"
echo ""
echo "Commands:"
echo "  Start:   /opt/etc/init.d/S90xkeen-web start"
echo "  Stop:    /opt/etc/init.d/S90xkeen-web stop"
echo "  Restart: /opt/etc/init.d/S90xkeen-web restart"
echo "  Status:  /opt/etc/init.d/S90xkeen-web status"
echo ""
echo "Configuration: /opt/etc/xkeen-web/xkeen-web.conf"
echo ""
echo "IMPORTANT: Change default password in config!"
echo "================================================"
echo ""

exit 0
EOF

chmod +x "${PKG_DIR}/CONTROL/postinst"

# Create prerm script
cat > "${PKG_DIR}/CONTROL/prerm" <<'EOF'
#!/bin/sh
set -e

echo "Stopping xkeen-web..."
/opt/etc/init.d/S90xkeen-web stop 2>/dev/null || true

exit 0
EOF

chmod +x "${PKG_DIR}/CONTROL/prerm"

# Create postrm script
cat > "${PKG_DIR}/CONTROL/postrm" <<'EOF'
#!/bin/sh
set -e

echo "xkeen-web removed"
echo "Config files preserved in /opt/etc/xkeen-web/"

exit 0
EOF

chmod +x "${PKG_DIR}/CONTROL/postrm"

# Create conffiles (files that shouldn't be overwritten on upgrade)
cat > "${PKG_DIR}/CONTROL/conffiles" <<EOF
/opt/etc/xkeen-web/xkeen-web.conf
EOF

# Build the package
echo "Building package..."
cd "$BUILD_DIR"

PKG_BUILD_DIR="${PKG_NAME}_${PKG_VERSION}-${PKG_RELEASE}_${PKG_ARCH}"

# Create control.tar.gz
cd "${PKG_BUILD_DIR}/CONTROL"
tar czvf ../../control.tar.gz .
cd ../..

# Create data.tar.gz (only the opt directory, not CONTROL)
cd "${PKG_BUILD_DIR}"
tar czvf ../data.tar.gz ./opt
cd ..

# Create debian-binary
echo "2.0" > debian-binary

# Create ipk package (using tar, same as nfqws-keenetic does)
IPK_FILE="${PKG_NAME}_${PKG_VERSION}-${PKG_RELEASE}_${PKG_ARCH}.ipk"
rm -f "$IPK_FILE"
tar czvf "$IPK_FILE" control.tar.gz data.tar.gz debian-binary

# Clean up temporary files
rm -f debian-binary control.tar.gz data.tar.gz

cd ..

echo ""
echo "================================================"
echo "Package built successfully!"
echo "================================================"
echo "File: ${BUILD_DIR}/${IPK_FILE}"
echo ""
echo "To install:"
echo "  1. Copy to router: scp ${BUILD_DIR}/${IPK_FILE} root@192.168.1.1:/tmp/"
echo "  2. SSH to router:  ssh root@192.168.1.1"
echo "  3. Install:        opkg install /tmp/${IPK_FILE}"
echo ""
echo "Or via wget:"
echo "  opkg update"
echo "  opkg install ${PKG_NAME}"
echo "================================================"
