# 📦 Complete Guide: Publishing xkeen-web to opkg

This guide will walk you through publishing `xkeen-web` to an opkg repository so users can install it with `opkg install xkeen-web`.

---

## 🎯 Quick Overview

1. **Build** the package (.ipk file)
2. **Create** repository structure
3. **Generate** package index
4. **Host** the repository (GitHub Pages, web server, etc.)
5. **Users install** from your repository

---

## 📋 Prerequisites

### On Your Development Machine

- Bash/WSL (you have this)
- `ar` and `tar` utilities (should be installed)
- Git (for GitHub Pages hosting)

### Optional Tools

```bash
# Install opkg-utils for advanced features (optional)
sudo apt-get install opkg-utils
```

---

## 🔨 Step 1: Build the Package

### 1.1 Build the .ipk Package

```bash
cd /home/user/xkeen-web

# Make build script executable
chmod +x build-opkg.sh verify-package.sh

# Build the package
./build-opkg.sh
```

This creates: `build/xkeen-web_1.0.0-1_all.ipk`

### 1.2 Verify the Package

```bash
./verify-package.sh
```

Expected output:
```
✅ Package verification PASSED
Package is ready for distribution!
```

---

## 📁 Step 2: Create Repository Structure

### 2.1 Create Repository Directory

```bash
# Create repository structure
mkdir -p ~/xkeen-web-repo/packages
cd ~/xkeen-web-repo
```

### 2.2 Copy Package to Repository

```bash
# Copy the built package
cp ~/xkeen-web/build/xkeen-web_1.0.0-1_all.ipk packages/
```

---

## 📇 Step 3: Generate Package Index

The package index tells opkg what packages are available.

### 3.1 Create Packages Index File

```bash
cd ~/xkeen-web-repo/packages

# Method 1: Simple script (recommended)
cat > make-index.sh << 'EOF'
#!/bin/bash
# Generate Packages index for opkg repository

PACKAGES_FILE="Packages"
> "$PACKAGES_FILE"

for ipk in *.ipk; do
    [ -e "$ipk" ] || continue
    
    # Extract control file
    ar p "$ipk" control.tar.gz | tar xzO ./control >> "$PACKAGES_FILE"
    
    # Add filename and size
    echo "Filename: $ipk" >> "$PACKAGES_FILE"
    echo "Size: $(stat -c%s "$ipk")" >> "$PACKAGES_FILE"
    
    # Add MD5sum
    echo "MD5Sum: $(md5sum "$ipk" | cut -d' ' -f1)" >> "$PACKAGES_FILE"
    
    # Add SHA256sum
    echo "SHA256sum: $(sha256sum "$ipk" | cut -d' ' -f1)" >> "$PACKAGES_FILE"
    
    # Add blank line between packages
    echo "" >> "$PACKAGES_FILE"
done

# Compress
gzip -c "$PACKAGES_FILE" > "${PACKAGES_FILE}.gz"

echo "✅ Package index created successfully!"
echo "   - Packages"
echo "   - Packages.gz"
EOF

chmod +x make-index.sh
./make-index.sh
```

### 3.2 Verify Index Was Created

```bash
ls -lh Packages*
# Should show:
# Packages
# Packages.gz
```

---

## 🌐 Step 4: Host the Repository

Choose one of the hosting methods below:

---

### Option A: GitHub Pages (Recommended - Free & Easy)

#### 4.1 Create GitHub Repository

```bash
cd ~/xkeen-web-repo

# Initialize git
git init
git branch -M main

# Create README
cat > README.md << 'EOF'
# xkeen-web opkg Repository

Official repository for xkeen-web package.

## Installation

```bash
# Add repository
echo "src/gz xkeen-web https://YOUR_USERNAME.github.io/xkeen-web-repo/packages" > /opt/etc/opkg/xkeen-web.conf

# Update and install
opkg update
opkg install xkeen-web
```

## Package Info

- **Name:** xkeen-web
- **Description:** Web interface for XKeen configuration
- **Port:** 91 (http://192.168.1.1:91)
- **Default Login:** root / keenetic

## Support

- [Issues](https://github.com/YOUR_USERNAME/xkeen-web/issues)
- [Documentation](https://github.com/YOUR_USERNAME/xkeen-web)
EOF

# Add files
git add .
git commit -m "Initial commit: xkeen-web v1.0.0"
```

#### 4.2 Push to GitHub

```bash
# Create repository on GitHub first, then:
git remote add origin https://github.com/YOUR_USERNAME/xkeen-web-repo.git
git push -u origin main
```

#### 4.3 Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings**
3. Scroll to **Pages** section
4. Under **Source**, select **main** branch
5. Click **Save**
6. Wait 1-2 minutes for deployment

Your repository will be available at:
```
https://YOUR_USERNAME.github.io/xkeen-web-repo/
```

---

### Option B: Your Own Web Server

#### 4.1 Upload Files

```bash
# Upload to your web server
scp -r packages/ user@yourserver.com:/var/www/html/xkeen-web/
```

#### 4.2 Configure Web Server

**For Nginx:**
```nginx
location /xkeen-web/packages/ {
    autoindex on;
    add_header Content-Type text/plain;
}
```

**For Apache:**
```apache
<Directory "/var/www/html/xkeen-web/packages">
    Options +Indexes
    AddType text/plain .ipk
</Directory>
```

---

### Option C: Self-Hosted on Keenetic Router

If you want to host on the router itself:

```bash
# On your Keenetic router
mkdir -p /opt/share/www/xkeen-web-repo
cp xkeen-web_1.0.0-1_all.ipk /opt/share/www/xkeen-web-repo/
cd /opt/share/www/xkeen-web-repo/

# Generate index
# (use the make-index.sh script from Step 3.1)

# Configure lighttpd or nginx to serve this directory
```

---

## 👥 Step 5: Users Can Now Install

### 5.1 User Installation Instructions

Share these instructions with users:

```bash
# 1. Add the repository
echo "src/gz xkeen-web https://YOUR_USERNAME.github.io/xkeen-web-repo/packages" > /opt/etc/opkg/xkeen-web.conf

# 2. Update package list
opkg update

# 3. Install xkeen-web
opkg install xkeen-web

# 4. Access web interface
# http://192.168.1.1:91
# Login: root / keenetic
```

### 5.2 Verify Installation Works

Test on a router:

```bash
# Check repository is accessible
opkg update | grep xkeen-web

# Check package is available
opkg list | grep xkeen-web

# Install
opkg install xkeen-web

# Verify it's running
ps | grep server.js
netstat -tlnp | grep :91
```

---

## 🔄 Step 6: Updating the Package

When you release a new version:

### 6.1 Update Version Number

```bash
cd ~/xkeen-web

# Update VERSION file
echo "1.0.1" > VERSION

# Update package.json
sed -i 's/"version": "1.0.0"/"version": "1.0.1"/' package.json
```

### 6.2 Rebuild and Update Repository

```bash
# Build new package
./build-opkg.sh

# Copy to repository
cp build/xkeen-web_1.0.1-1_all.ipk ~/xkeen-web-repo/packages/

# Regenerate index
cd ~/xkeen-web-repo/packages
./make-index.sh

# Commit and push
cd ~/xkeen-web-repo
git add .
git commit -m "Release v1.0.1"
git push
```

### 6.3 Users Update

```bash
opkg update
opkg upgrade xkeen-web
```

---

## 📚 Advanced: Submit to Official Entware

To submit to the official Entware repository:

### 1. Fork Entware Repository

```bash
# Fork https://github.com/Entware/Entware
git clone https://github.com/YOUR_USERNAME/Entware.git
cd Entware
```

### 2. Add Your Package

```bash
# Copy your Makefile
cp ~/xkeen-web/Makefile package/net/xkeen-web/Makefile

# Copy files directory
cp -r ~/xkeen-web/files package/net/xkeen-web/
```

### 3. Test Build

```bash
make package/xkeen-web/compile V=s
```

### 4. Submit Pull Request

1. Commit your changes
2. Push to your fork
3. Create Pull Request to Entware/Entware
4. Wait for maintainer review

---

## 🛡️ Package Signing (Optional but Recommended)

### Generate GPG Key

```bash
# Generate key
gpg --full-generate-key

# Export public key
gpg --armor --export your-email@example.com > xkeen-web-repo.pub
```

### Sign Packages

```bash
cd ~/xkeen-web-repo/packages

# Sign each package
for ipk in *.ipk; do
    gpg --detach-sign --armor "$ipk"
done

# Update index
./make-index.sh
```

### Users Import Key

```bash
# Users download and trust your key
wget https://YOUR_USERNAME.github.io/xkeen-web-repo/xkeen-web-repo.pub
opkg-key add xkeen-web-repo.pub
```

---

## 📊 Repository Statistics & Monitoring

### Track Downloads with GitHub

GitHub provides analytics for Pages:
- Go to repository → Insights → Traffic

### Custom Analytics

Add to your repository README:

```markdown
![Downloads](https://img.shields.io/github/downloads/YOUR_USERNAME/xkeen-web-repo/total)
![Version](https://img.shields.io/github/v/release/YOUR_USERNAME/xkeen-web-repo)
```

---

## 🔧 Troubleshooting

### Problem: opkg update fails

**Solution:**
```bash
# Check repository URL is accessible
curl https://YOUR_USERNAME.github.io/xkeen-web-repo/packages/Packages

# Check Packages.gz exists
curl -I https://YOUR_USERNAME.github.io/xkeen-web-repo/packages/Packages.gz
```

### Problem: Package not found

**Solution:**
```bash
# Verify package is in index
curl https://YOUR_USERNAME.github.io/xkeen-web-repo/packages/Packages | grep "Package: xkeen-web"

# Regenerate index
cd ~/xkeen-web-repo/packages
./make-index.sh
```

### Problem: Installation fails

**Solution:**
```bash
# Check dependencies
opkg info node

# Check disk space
df -h

# Try verbose install
opkg install -V xkeen-web
```

---

## ✅ Checklist: Ready to Publish?

- [ ] Package builds successfully (`./build-opkg.sh`)
- [ ] Package verification passes (`./verify-package.sh`)
- [ ] Packages index created
- [ ] Repository hosted and accessible
- [ ] README with installation instructions
- [ ] Tested installation on actual router
- [ ] Version number is correct
- [ ] All documentation updated

---

## 📞 Support & Resources

- **Package Issues:** Open issue on GitHub
- **Build Issues:** Check OPKG_PACKAGING.md
- **General Help:** See README.md

---

## 🎉 Quick Start Command Summary

```bash
# Build
cd ~/xkeen-web && ./build-opkg.sh

# Create repo
mkdir -p ~/xkeen-web-repo/packages
cp build/*.ipk ~/xkeen-web-repo/packages/

# Generate index
cd ~/xkeen-web-repo/packages
# (use make-index.sh script from Step 3.1)

# Push to GitHub
cd ~/xkeen-web-repo
git init && git add . && git commit -m "Initial release"
git remote add origin https://github.com/YOUR_USERNAME/xkeen-web-repo.git
git push -u origin main

# Enable GitHub Pages in repository settings

# Done! Users can now install:
# opkg update && opkg install xkeen-web
```

---

**Your repository URL will be:**
```
https://YOUR_USERNAME.github.io/xkeen-web-repo/packages
```

**Users add it with:**
```bash
echo "src/gz xkeen-web https://YOUR_USERNAME.github.io/xkeen-web-repo/packages" > /opt/etc/opkg/xkeen-web.conf
```

---

**Good luck with your package! 🚀**
