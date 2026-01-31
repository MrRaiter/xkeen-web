# ✅ Port Change Summary

## What Changed

The default port has been changed from **90 to 91** to avoid conflicts with nfqws-keenetic-web.

## Reason

- **Port 90** is typically used by **nfqws-keenetic-web**
- **Port 91** is now used by **xkeen-web-ui**
- This allows both services to run simultaneously on the same router

## Files Updated

### Core Application
- ✅ `server.js` - Default PORT changed to 91
- ✅ `files/xkeen-web-ui.conf` - Default PORT=91
- ✅ `files/S90xkeen-web-ui` - Init script default PORT=91
- ✅ `.env.example` - Example PORT=91
- ✅ `init.d-example` - Example PORT=91

### Documentation
- ✅ `README.md` - All port references updated
- ✅ `QUICK_START.md` - Access URL updated to :91
- ✅ `OPKG_PACKAGING.md` - Examples updated
- ✅ `IMPLEMENTATION_COMPLETE.md` - All references updated
- ✅ `CONTRIBUTING.md` - Developer guide updated
- ✅ `PROJECT_SUMMARY.md` - Technical docs updated

### Build Files
- ✅ `Makefile` - Install messages updated
- ✅ `build-opkg.sh` - Post-install message updated
- ✅ `install-manual.sh` - Installation script updated

## New Default Access

After installation, access xkeen-web-ui at:

```
http://192.168.1.1:91
```

## Port Configuration

You can still change the port if needed:

```bash
# Edit configuration
nano /opt/etc/xkeen-web-ui/xkeen-web-ui.conf

# Change PORT to any available port
PORT=8091

# Restart service
/opt/etc/init.d/S90xkeen-web-ui restart
```

## Verification

Check which ports are in use:

```bash
# Check nfqws-keenetic-web (should be on port 90)
netstat -tlnp | grep :90

# Check xkeen-web-ui (should be on port 91)
netstat -tlnp | grep :91
```

## Both Services Running

You can now run both web interfaces simultaneously:

- **nfqws-keenetic-web**: http://192.168.1.1:90
- **xkeen-web-ui**: http://192.168.1.1:91

## No Action Required

If you haven't built the package yet, the new default will be used automatically.

If you've already installed with port 90, you can:
1. Rebuild the package with the new settings
2. Or manually change the port in `/opt/etc/xkeen-web-ui/xkeen-web-ui.conf`

---

**All changes are complete and ready to use!** 🎉
