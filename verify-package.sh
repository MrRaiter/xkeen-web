#!/bin/bash

# Package verification script
# Checks if the package is correctly built and contains all necessary files

set -e

PKG_VERSION=$(cat VERSION)
BUILD_DIR="build"
IPK_FILE="${BUILD_DIR}/xkeen-web-ui_${PKG_VERSION}-1_all.ipk"

echo "=================================="
echo "xkeen-web-ui Package Verification"
echo "=================================="
echo ""

# Check if package exists
if [ ! -f "$IPK_FILE" ]; then
    echo "❌ Package not found: $IPK_FILE"
    echo "Run ./build-opkg.sh first"
    exit 1
fi

echo "✅ Package found: $IPK_FILE"
echo ""

# Get package size
PKG_SIZE=$(du -h "$IPK_FILE" | cut -f1)
echo "📦 Package size: $PKG_SIZE"
echo ""

# Extract and verify contents
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

echo "🔍 Extracting package..."
ar x "$OLDPWD/$IPK_FILE"

if [ ! -f "control.tar.gz" ] || [ ! -f "data.tar.gz" ]; then
    echo "❌ Invalid package structure"
    exit 1
fi

echo "✅ Package structure valid"
echo ""

# Check control files
echo "📋 Control files:"
tar tzf control.tar.gz | while read file; do
    echo "  ✓ $file"
done
echo ""

# Check data files
echo "📁 Data files:"
tar tzf data.tar.gz | while read file; do
    echo "  ✓ $file"
done
echo ""

# Extract control
mkdir -p control
tar xzf control.tar.gz -C control

echo "📝 Package metadata:"
cat control/control
echo ""

# Check required files
REQUIRED_FILES=(
    "opt/xkeen-web-ui/server.js"
    "opt/xkeen-web-ui/package.json"
    "opt/xkeen-web-ui/VERSION"
    "opt/xkeen-web-ui/public/index.html"
    "opt/etc/init.d/S90xkeen-web-ui"
    "opt/etc/xkeen-web-ui/xkeen-web-ui.conf"
)

echo "🔍 Verifying required files..."
mkdir -p data
tar xzf data.tar.gz -C data

ALL_FOUND=true
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "data/$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ Missing: $file"
        ALL_FOUND=false
    fi
done
echo ""

# Check file permissions
echo "🔐 Checking permissions..."
if [ -x "data/opt/xkeen-web-ui/server.js" ]; then
    echo "  ✅ server.js is executable"
else
    echo "  ❌ server.js is not executable"
    ALL_FOUND=false
fi

if [ -x "data/opt/etc/init.d/S90xkeen-web-ui" ]; then
    echo "  ✅ S90xkeen-web-ui is executable"
else
    echo "  ❌ S90xkeen-web-ui is not executable"
    ALL_FOUND=false
fi
echo ""

# Check install scripts
echo "📜 Install scripts:"
for script in postinst prerm postrm; do
    if [ -f "control/$script" ]; then
        if [ -x "control/$script" ]; then
            echo "  ✅ $script (executable)"
        else
            echo "  ⚠️  $script (not executable)"
        fi
    else
        echo "  ❌ Missing: $script"
    fi
done
echo ""

# Calculate installed size
INSTALLED_SIZE=$(du -sh data | cut -f1)
echo "💾 Installed size: $INSTALLED_SIZE"
echo ""

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

if [ "$ALL_FOUND" = true ]; then
    echo "=================================="
    echo "✅ Package verification PASSED"
    echo "=================================="
    echo ""
    echo "Package is ready for distribution!"
    echo ""
    echo "To install:"
    echo "  scp $IPK_FILE root@192.168.1.1:/tmp/"
    echo "  ssh root@192.168.1.1 'opkg install /tmp/$(basename $IPK_FILE)'"
    echo ""
    exit 0
else
    echo "=================================="
    echo "❌ Package verification FAILED"
    echo "=================================="
    echo ""
    echo "Please fix the issues and rebuild"
    exit 1
fi
