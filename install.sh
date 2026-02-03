#!/bin/sh
# xkeen-web Installer for Keenetic routers
# Run this on your router after copying files

set -e

echo "=========================================="
echo "  xkeen-web Installer v1.1.0"
echo "=========================================="
echo ""

# Check if Node.js is installed
if ! command -v node >/dev/null 2>&1; then
    echo "Error: Node.js is not installed!"
    echo "Please install it first: opkg update && opkg install node"
    exit 1
fi

# Get script directory (where the tar.gz was extracted)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Stop existing service if running
if [ -f /opt/etc/init.d/S90xkeen-web ]; then
    echo "Stopping existing service..."
    /opt/etc/init.d/S90xkeen-web stop 2>/dev/null || true
fi

# Clean up old installation
echo "Removing old installation..."
rm -rf /opt/xkeen-web
rm -rf /opt/etc/xkeen-web
rm -f /opt/etc/init.d/S90xkeen-web

# Create directories
echo "Creating directories..."
mkdir -p /opt/xkeen-web/public
mkdir -p /opt/etc/xkeen-web

# Copy files
echo "Installing files..."
cp "$SCRIPT_DIR/server.js" /opt/xkeen-web/
cp "$SCRIPT_DIR/package.json" /opt/xkeen-web/
cp "$SCRIPT_DIR/VERSION" /opt/xkeen-web/
cp "$SCRIPT_DIR/public/index.html" /opt/xkeen-web/public/

# Copy init.d script
cp "$SCRIPT_DIR/files/S90xkeen-web" /opt/etc/init.d/

# Copy config (don't overwrite existing)
if [ ! -f /opt/etc/xkeen-web/xkeen-web.conf ]; then
    cp "$SCRIPT_DIR/files/xkeen-web.conf" /opt/etc/xkeen-web/
    echo "Created default config file"
else
    echo "Keeping existing config file"
fi

# Set permissions
chmod +x /opt/xkeen-web/server.js
chmod +x /opt/etc/init.d/S90xkeen-web

# Create xray config directory if not exists
[ -d /opt/etc/xray/configs ] || mkdir -p /opt/etc/xray/configs

echo ""
echo "=========================================="
echo "  Installation Complete!"
echo "=========================================="
echo ""
echo "Access: http://$(ip -4 addr show br0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | head -1 || echo "ROUTER_IP"):91"
echo ""
echo "Default credentials:"
echo "  Username: root"
echo "  Password: keenetic"
echo ""
echo "Commands:"
echo "  Start:   /opt/etc/init.d/S90xkeen-web start"
echo "  Stop:    /opt/etc/init.d/S90xkeen-web stop"
echo "  Restart: /opt/etc/init.d/S90xkeen-web restart"
echo ""
echo "Config:  /opt/etc/xkeen-web/xkeen-web.conf"
echo ""
echo "IMPORTANT: Change default password in config!"
echo "=========================================="
echo ""

# Ask to start
printf "Start xkeen-web now? [Y/n]: "
read -r response
case "$response" in
    [nN][oO]|[nN]) 
        echo "Run '/opt/etc/init.d/S90xkeen-web start' when ready"
        ;;
    *)
        /opt/etc/init.d/S90xkeen-web start
        echo ""
        echo "xkeen-web started!"
        ;;
esac
