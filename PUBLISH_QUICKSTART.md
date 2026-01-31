# 🚀 Quick Start: Publish to opkg in 5 Minutes

## Step 1: Build Package (30 seconds)

```bash
cd /home/user/xkeen-web
chmod +x build-opkg.sh
./build-opkg.sh
```

Output: `build/xkeen-web_1.0.0-1_all.ipk` ✅

---

## Step 2: Create Repository (1 minute)

```bash
# Create directory
mkdir -p ~/xkeen-web-repo/packages
cd ~/xkeen-web-repo

# Copy package
cp ~/xkeen-web/build/xkeen-web_1.0.0-1_all.ipk packages/
```

---

## Step 3: Generate Index (1 minute)

```bash
cd ~/xkeen-web-repo/packages

# Create index script
cat > make-index.sh << 'SCRIPT'
#!/bin/bash
PACKAGES_FILE="Packages"
> "$PACKAGES_FILE"

for ipk in *.ipk; do
    [ -e "$ipk" ] || continue
    ar p "$ipk" control.tar.gz | tar xzO ./control >> "$PACKAGES_FILE"
    echo "Filename: $ipk" >> "$PACKAGES_FILE"
    echo "Size: $(stat -c%s "$ipk")" >> "$PACKAGES_FILE"
    echo "MD5Sum: $(md5sum "$ipk" | cut -d' ' -f1)" >> "$PACKAGES_FILE"
    echo "SHA256sum: $(sha256sum "$ipk" | cut -d' ' -f1)" >> "$PACKAGES_FILE"
    echo "" >> "$PACKAGES_FILE"
done

gzip -c "$PACKAGES_FILE" > "${PACKAGES_FILE}.gz"
echo "✅ Index created!"
SCRIPT

chmod +x make-index.sh
./make-index.sh
```

---

## Step 4: Push to GitHub Pages (2 minutes)

```bash
cd ~/xkeen-web-repo

# Create README
cat > README.md << 'EOF'
# xkeen-web Repository

Install xkeen-web with opkg!

## Installation

```bash
echo "src/gz xkeen-web https://YOUR_USERNAME.github.io/xkeen-web-repo/packages" > /opt/etc/opkg/xkeen-web.conf
opkg update
opkg install xkeen-web
```

Access: http://192.168.1.1:91
EOF

# Initialize git
git init
git branch -M main
git add .
git commit -m "Initial release: xkeen-web v1.0.0"

# Push (create repo on GitHub first!)
git remote add origin https://github.com/YOUR_USERNAME/xkeen-web-repo.git
git push -u origin main
```

**Enable GitHub Pages:**
1. Go to repository **Settings**
2. Click **Pages**
3. Select **main** branch
4. Click **Save**

Wait 2 minutes for deployment.

---

## Step 5: Share Installation Instructions (30 seconds)

Your repository URL:
```
https://YOUR_USERNAME.github.io/xkeen-web-repo/packages
```

Share with users:

```bash
# Add repository
echo "src/gz xkeen-web https://YOUR_USERNAME.github.io/xkeen-web-repo/packages" > /opt/etc/opkg/xkeen-web.conf

# Install
opkg update
opkg install xkeen-web

# Access
# http://192.168.1.1:91
# Login: root / keenetic
```

---

## ✅ Done!

Users can now install with:
```bash
opkg install xkeen-web
```

---

## 🔄 Update Package Later

```bash
# 1. Update version
echo "1.0.1" > ~/xkeen-web/VERSION

# 2. Rebuild
cd ~/xkeen-web && ./build-opkg.sh

# 3. Copy new package
cp build/xkeen-web_1.0.1-1_all.ipk ~/xkeen-web-repo/packages/

# 4. Regenerate index
cd ~/xkeen-web-repo/packages && ./make-index.sh

# 5. Push to GitHub
cd ~/xkeen-web-repo
git add . && git commit -m "Release v1.0.1" && git push
```

Users update with:
```bash
opkg update && opkg upgrade xkeen-web
```

---

**See OPKG_PUBLISHING_GUIDE.md for detailed instructions.**
