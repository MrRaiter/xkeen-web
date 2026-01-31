# Makefile for xkeen-web opkg package

include $(TOPDIR)/rules.mk

PKG_NAME:=xkeen-web
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/xkeen-web
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Web interface for XKeen configuration management
	URL:=https://github.com/yourusername/xkeen-web
	MAINTAINER:=Your Name <your@email.com>
	DEPENDS:=+node +xkeen
	PKGARCH:=all
endef

define Package/xkeen-web/description
	Lightweight web interface for XKeen configuration management.
	Built with pure Node.js (zero dependencies).
	Features: config editor, service control, authentication, dark/light theme.
	Access via http://192.168.1.1:90
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./server.js $(PKG_BUILD_DIR)/
	$(CP) ./public $(PKG_BUILD_DIR)/
	$(CP) ./package.json $(PKG_BUILD_DIR)/
	$(CP) ./VERSION $(PKG_BUILD_DIR)/
endef

define Build/Compile
	# Nothing to compile - pure JavaScript
endef

define Package/xkeen-web/install
	$(INSTALL_DIR) $(1)/opt/xkeen-web
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/server.js $(1)/opt/xkeen-web/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/package.json $(1)/opt/xkeen-web/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/VERSION $(1)/opt/xkeen-web/
	
	$(INSTALL_DIR) $(1)/opt/xkeen-web/public
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/public/index.html $(1)/opt/xkeen-web/public/
	
	$(INSTALL_DIR) $(1)/opt/etc/init.d
	$(INSTALL_BIN) ./files/S90xkeen-web $(1)/opt/etc/init.d/
	
	$(INSTALL_DIR) $(1)/opt/etc/xkeen-web
	$(INSTALL_DATA) ./files/xkeen-web.conf $(1)/opt/etc/xkeen-web/
endef

define Package/xkeen-web/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Configuring xkeen-web..."
	
	# Set executable permissions
	chmod +x /opt/xkeen-web/server.js
	chmod +x /opt/etc/init.d/S90xkeen-web
	
	# Create config directory if not exists
	[ -d /opt/etc/xkeen ] || mkdir -p /opt/etc/xkeen
	
	echo "xkeen-web installed successfully!"
	echo "Access the web interface at http://192.168.1.1:91"
	echo "Default credentials: root / keenetic"
	echo "Note: Port 91 is used (port 90 is for nfqws-keenetic-web)"
	echo ""
	echo "To start: /opt/etc/init.d/S90xkeen-web start"
	echo "To enable on boot: already enabled via init.d"
fi
exit 0
endef

define Package/xkeen-web/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Stopping xkeen-web..."
	/opt/etc/init.d/S90xkeen-web stop 2>/dev/null || true
fi
exit 0
endef

define Package/xkeen-web/postrm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "xkeen-web removed"
	echo "Config files preserved in /opt/etc/xkeen-web/"
fi
exit 0
endef

$(eval $(call BuildPackage,xkeen-web))
