#!/bin/sh

# Uninstallation script for xkeen-web-ui

set -e

echo "Uninstalling xkeen-web-ui..."

# Stop service
echo "Stopping service..."
/opt/etc/init.d/S90xkeen-web-ui stop 2>/dev/null || true

# Remove files
echo "Removing files..."
rm -rf /opt/xkeen-web-ui
rm -f /opt/etc/init.d/S90xkeen-web-ui

# Ask about config
printf "Remove configuration files? [y/N]: "
read -r response
case "$response" in
    [yY][eE][sS]|[yY]) 
        rm -rf /opt/etc/xkeen-web-ui
        echo "Configuration removed"
        ;;
    *)
        echo "Configuration preserved at /opt/etc/xkeen-web-ui/"
        ;;
esac

echo ""
echo "xkeen-web-ui uninstalled successfully!"
