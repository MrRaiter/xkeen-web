#!/bin/bash
set -e

VERSION=$(cat VERSION)
PKG_NAME="xkeen-web"
PKG_VERSION="${VERSION}-1"
ARCH="aarch64-3.10"  # Keenetic ARM64

BUILD_DIR="build"
PKG_DIR="${BUILD_DIR}/pkg"

echo "Building ${PKG_NAME} version ${PKG_VERSION}..."

# Clean
rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${PKG_DIR}"

# Build Go binary for ARM64
echo "Compiling Go binary for linux/arm64..."
CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags="-s -w -X main.version=${VERSION}" -o "${BUILD_DIR}/xkeen-web" .

# Check binary size
BINARY_SIZE=$(stat -c%s "${BUILD_DIR}/xkeen-web" 2>/dev/null || stat -f%z "${BUILD_DIR}/xkeen-web")
echo "Binary size: $(numfmt --to=iec ${BINARY_SIZE} 2>/dev/null || echo "${BINARY_SIZE} bytes")"

# Optional: compress with upx if available
if command -v upx &> /dev/null; then
    echo "Compressing with upx..."
    upx --best --lzma "${BUILD_DIR}/xkeen-web" || true
    COMPRESSED_SIZE=$(stat -c%s "${BUILD_DIR}/xkeen-web" 2>/dev/null || stat -f%z "${BUILD_DIR}/xkeen-web")
    echo "Compressed size: $(numfmt --to=iec ${COMPRESSED_SIZE} 2>/dev/null || echo "${COMPRESSED_SIZE} bytes")"
fi

# Create package structure
mkdir -p "${PKG_DIR}/opt/xkeen-web"
mkdir -p "${PKG_DIR}/opt/etc/init.d"
mkdir -p "${PKG_DIR}/opt/etc/xkeen-web"
mkdir -p "${PKG_DIR}/CONTROL"

# Copy binary
cp "${BUILD_DIR}/xkeen-web" "${PKG_DIR}/opt/xkeen-web/"
chmod 755 "${PKG_DIR}/opt/xkeen-web/xkeen-web"

# Copy VERSION file
echo "${VERSION}" > "${PKG_DIR}/opt/xkeen-web/VERSION"

# Create init script
cat > "${PKG_DIR}/opt/etc/init.d/S90xkeen-web" << 'INITEOF'
#!/bin/sh

ENABLED=yes
PROCS=xkeen-web
ARGS=""
PREARGS=""
DESC="xkeen Web UI"
PATH=/opt/sbin:/opt/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

. /opt/etc/init.d/rc.func
INITEOF
chmod 755 "${PKG_DIR}/opt/etc/init.d/S90xkeen-web"

# Create default config
cat > "${PKG_DIR}/opt/etc/xkeen-web/xkeen-web.conf" << 'CONFEOF'
# xkeen-web configuration

# Web server port
PORT=91

# Xray config directory
XKEEN_CONFIG=/opt/etc/xray/configs

# Service command
XKEEN_SERVICE=/opt/sbin/xkeen

# Authentication
XKEEN_USER=root
XKEEN_PASS=keenetic
CONFEOF

# Create control file
cat > "${PKG_DIR}/CONTROL/control" << EOF
Package: ${PKG_NAME}
Version: ${PKG_VERSION}
Architecture: ${ARCH}
Maintainer: xkeen-web
Section: net
Priority: optional
Homepage: https://github.com/xkeen-web/xkeen-web
Description: Web UI for XKeen/Xray configuration management
 A lightweight web interface for managing XKeen/Xray VPN configurations.
 Single binary with embedded web UI - no dependencies required.
EOF

# Create postinst script
cat > "${PKG_DIR}/CONTROL/postinst" << 'EOF'
#!/bin/sh
mkdir -p /opt/etc/xray/configs
# Create symlink so init script can find the binary
ln -sf /opt/xkeen-web/xkeen-web /opt/bin/xkeen-web
echo "xkeen-web installed. Start with: /opt/etc/init.d/S90xkeen-web start"
echo "Web UI available at: http://$(hostname -i 2>/dev/null || echo 'router'):91"
EOF
chmod 755 "${PKG_DIR}/CONTROL/postinst"

# Create prerm script
cat > "${PKG_DIR}/CONTROL/prerm" << 'EOF'
#!/bin/sh
/opt/etc/init.d/S90xkeen-web stop 2>/dev/null || true
rm -f /opt/bin/xkeen-web
EOF
chmod 755 "${PKG_DIR}/CONTROL/prerm"

# Create conffiles
cat > "${PKG_DIR}/CONTROL/conffiles" << 'EOF'
/opt/etc/xkeen-web/xkeen-web.conf
EOF

# Build IPK package
echo "Creating IPK package..."
cd "${PKG_DIR}"

# Create debian-binary
echo "2.0" > debian-binary

# Create control.tar.gz
cd CONTROL
tar czvf ../control.tar.gz ./*
cd ..

# Create data.tar.gz
tar czvf data.tar.gz ./opt

# Create final IPK (tar format for Entware compatibility)
tar czvf "../${PKG_NAME}_${PKG_VERSION}_${ARCH}.ipk" ./debian-binary ./control.tar.gz ./data.tar.gz

cd ../..

echo ""
echo "================================================"
echo "Package built successfully!"
echo "================================================"
echo "File: ${BUILD_DIR}/${PKG_NAME}_${PKG_VERSION}_${ARCH}.ipk"
echo ""
echo "To install:"
echo "  1. Copy to router: scp ${BUILD_DIR}/${PKG_NAME}_${PKG_VERSION}_${ARCH}.ipk root@router:/tmp/"
echo "  2. SSH to router and run: opkg install /tmp/${PKG_NAME}_${PKG_VERSION}_${ARCH}.ipk"
echo "================================================"
