# ✅ Rename Complete: xkeen-web-ui → xkeen-web

## What Changed

All references to "xkeen-web-ui" have been renamed to "xkeen-web" throughout the project.

---

## Files Renamed

### Scripts & Config
- ✅ `files/S90xkeen-web-ui` → `files/S90xkeen-web`
- ✅ `files/xkeen-web-ui.conf` → `files/xkeen-web.conf`

### All References Updated In:
- ✅ `package.json` - Package name and URLs
- ✅ `Makefile` - Package name and paths
- ✅ `build-opkg.sh` - All paths and messages
- ✅ `install-manual.sh` - Installation paths
- ✅ `uninstall.sh` - Removal paths
- ✅ `start.sh` - Startup paths
- ✅ `init.d-example` - Example script
- ✅ `verify-package.sh` - Verification script
- ✅ `.env.example` - Environment template
- ✅ `.github/workflows/build-package.yml` - CI/CD workflow
- ✅ All `.md` files - Documentation

---

## New Paths After Installation

### On Router:
```
/opt/xkeen-web/              (was: /opt/xkeen-web-ui/)
├── server.js
├── package.json
├── VERSION
└── public/
    └── index.html

/opt/etc/init.d/
└── S90xkeen-web            (was: S90xkeen-web-ui)

/opt/etc/xkeen-web/         (was: /opt/etc/xkeen-web-ui/)
└── xkeen-web.conf          (was: xkeen-web-ui.conf)
```

---

## Package Name

- **Old:** `xkeen-web-ui_1.0.0-1_all.ipk`
- **New:** `xkeen-web_1.0.0-1_all.ipk`

---

## Installation Commands

### Old:
```bash
opkg install xkeen-web-ui
/opt/etc/init.d/S90xkeen-web-ui start
```

### New:
```bash
opkg install xkeen-web
/opt/etc/init.d/S90xkeen-web start
```

---

## Access URL (Unchanged)

```
http://192.168.1.1:91
```

Login: `root` / `keenetic`

---

## Build & Publish

### Build Package:
```bash
cd /home/user/xkeen-web
./build-opkg.sh
```

Output: `build/xkeen-web_1.0.0-1_all.ipk`

### Quick Publish:
See **PUBLISH_QUICKSTART.md** for 5-minute guide

### Detailed Publishing:
See **OPKG_PUBLISHING_GUIDE.md** for complete instructions

---

## Ready to Use! ✅

Everything is renamed and ready to build/publish.

The package name is now cleaner: **xkeen-web** instead of xkeen-web-ui.

---

**Next steps:**
1. Build the package: `./build-opkg.sh`
2. Follow PUBLISH_QUICKSTART.md to publish to opkg
3. Share with users!
