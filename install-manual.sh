#!/bin/sh

# Manual installation script for xkeen-web-ui
# Use this if you don't have the ipk package

set -e

echo "Installing xkeen-web-ui manually..."

# Check if Node.js is installed
if ! command -v node >/dev/null 2>&1; then
    echo "Error: Node.js is not installed!"
    echo "Please install it first: opkg update && opkg install node"
    exit 1
fi

# Check if XKeen is installed
if [ ! -d "/opt/etc/xkeen" ]; then
    echo "Warning: XKeen directory not found at /opt/etc/xkeen"
    echo "Creating directory..."
    mkdir -p /opt/etc/xkeen
fi

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Create installation directory
echo "Creating directories..."
mkdir -p /opt/xkeen-web-ui
mkdir -p /opt/xkeen-web-ui/public
mkdir -p /opt/etc/xkeen-web-ui

# Copy files
echo "Copying files..."
cp "$SCRIPT_DIR/server.js" /opt/xkeen-web-ui/
cp "$SCRIPT_DIR/package.json" /opt/xkeen-web-ui/
cp "$SCRIPT_DIR/VERSION" /opt/xkeen-web-ui/
cp "$SCRIPT_DIR/public/index.html" /opt/xkeen-web-ui/public/

# Set permissions
chmod +x /opt/xkeen-web-ui/server.js

# Copy init.d script
echo "Installing init.d script..."
cp "$SCRIPT_DIR/files/S90xkeen-web-ui" /opt/etc/init.d/
chmod +x /opt/etc/init.d/S90xkeen-web-ui

# Copy config file (don't overwrite if exists)
if [ ! -f "/opt/etc/xkeen-web-ui/xkeen-web-ui.conf" ]; then
    echo "Creating config file..."
    cp "$SCRIPT_DIR/files/xkeen-web-ui.conf" /opt/etc/xkeen-web-ui/
else
    echo "Config file already exists, skipping..."
fi

echo ""
echo "================================================"
echo "xkeen-web-ui installed successfully!"
echo "================================================"
echo ""
echo "Access: http://192.168.1.1:91"
echo "Note: Port 91 is used (port 90 is for nfqws-keenetic-web)"
echo "Default credentials:"
echo "  Username: root"
echo "  Password: keenetic"
echo ""
echo "Commands:"
echo "  Start:   /opt/etc/init.d/S90xkeen-web-ui start"
echo "  Stop:    /opt/etc/init.d/S90xkeen-web-ui stop"
echo "  Restart: /opt/etc/init.d/S90xkeen-web-ui restart"
echo "  Status:  /opt/etc/init.d/S90xkeen-web-ui status"
echo ""
echo "Configuration: /opt/etc/xkeen-web-ui/xkeen-web-ui.conf"
echo ""
echo "IMPORTANT: Change default password!"
echo "  Edit: /opt/etc/xkeen-web-ui/xkeen-web-ui.conf"
echo "  Then restart: /opt/etc/init.d/S90xkeen-web-ui restart"
echo "================================================"
echo ""

# Ask if user wants to start now
printf "Start xkeen-web-ui now? [y/N]: "
read -r response
case "$response" in
    [yY][eE][sS]|[yY]) 
        /opt/etc/init.d/S90xkeen-web-ui start
        echo ""
        echo "xkeen-web-ui started!"
        echo "Access at: http://192.168.1.1:91"
        ;;
    *)
        echo "You can start it later with: /opt/etc/init.d/S90xkeen-web-ui start"
        ;;
esac
