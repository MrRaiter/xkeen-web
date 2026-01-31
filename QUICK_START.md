# Quick Start Guide

Get xkeen-web-ui running in 5 minutes!

## 🚀 Installation (Choose One Method)

### Option A: Install via opkg (Easiest)

```bash
# On your Keenetic router (via SSH)
opkg update
opkg install xkeen-web-ui

# Start the service
/opt/etc/init.d/S90xkeen-web-ui start
```

### Option B: Manual Installation

```bash
# Download
cd /tmp
wget https://github.com/yourusername/xkeen-web-ui/archive/main.tar.gz
tar xzf main.tar.gz
cd xkeen-web-ui-main

# Install
chmod +x install-manual.sh
./install-manual.sh
```

### Option C: Quick Test (Development)

```bash
# Just run it
node server.js
```

## 🌐 Access the Interface

Open your browser:

```
http://192.168.1.1:91
```

**Note:** We use port 91 because port 90 is typically used by nfqws-keenetic-web.

## 🔐 Login

Default credentials:
- **Username:** `root`
- **Password:** `keenetic`

⚠️ **Important:** Change these after first login!

## ⚙️ Configuration

Edit configuration file:

```bash
nano /opt/etc/xkeen-web-ui/xkeen-web-ui.conf
```

Change credentials:

```bash
XKEEN_USER=yourusername
XKEEN_PASS=yourpassword
```

Restart service:

```bash
/opt/etc/init.d/S90xkeen-web-ui restart
```

## 📝 Basic Usage

1. **Select a file** - Click on tabs at the top
2. **Edit content** - Type in the text area
3. **Save changes** - Click "Save" or press `Ctrl+S`
4. **Control service** - Use the "Menu" dropdown
5. **Toggle theme** - Menu → Toggle Theme

## 🛠️ Common Commands

```bash
# Service management
/opt/etc/init.d/S90xkeen-web-ui start    # Start
/opt/etc/init.d/S90xkeen-web-ui stop     # Stop
/opt/etc/init.d/S90xkeen-web-ui restart  # Restart
/opt/etc/init.d/S90xkeen-web-ui status   # Check status

# Check if running
ps | grep server.js

# View logs
logread | grep xkeen-web-ui

# Update package (if installed via opkg)
opkg update
opkg upgrade xkeen-web-ui
```

## 🔧 Troubleshooting

### Can't access the web interface?

```bash
# Check if service is running
ps | grep server.js

# Check port
netstat -tlnp | grep :91

# Restart service
/opt/etc/init.d/S90xkeen-web-ui restart
```

### Forgot password?

Reset in config file:

```bash
nano /opt/etc/xkeen-web-ui/xkeen-web-ui.conf
# Change XKEEN_PASS
/opt/etc/init.d/S90xkeen-web-ui restart
```

### Port 91 already in use?

Change port in config:

```bash
nano /opt/etc/xkeen-web-ui/xkeen-web-ui.conf
# Change PORT=91 to PORT=8091 (or any available port)
/opt/etc/init.d/S90xkeen-web-ui restart
```

Access at: http://192.168.1.1:8091

## 📚 Next Steps

- Read the [full README](README.md) for detailed information
- Check [OPKG_PACKAGING.md](OPKG_PACKAGING.md) to build your own package
- See [CONTRIBUTING.md](CONTRIBUTING.md) to contribute

## 💡 Tips

- **Port Info:** xkeen-web-ui uses port 91, nfqws-keenetic-web uses port 90
- Use `Ctrl+S` to quickly save files
- The save button pulses when you have unsaved changes
- Service status indicator: 🟢 running, 🔴 stopped
- Config files are automatically backed up before saving
- Theme preference is saved in your browser

## 🆘 Need Help?

- [Open an issue](https://github.com/yourusername/xkeen-web-ui/issues)
- Check the [troubleshooting section](README.md#troubleshooting)
- Review [XKeen documentation](https://github.com/Skrill0/XKeen)

---

Enjoy using xkeen-web-ui! 🎉
