include $(TOPDIR)/rules.mk

PKG_NAME:=luci-app-v2ray
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=MoeGrid <1065380934@qq.com>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/luci-app-v2ray/Default
	SECTION:=luci
	CATEGORY:=LuCI
	SUBMENU:=3. Applications
	TITLE:=LuCI Support for v2ray-core
	DEPENDS:=+coreutils-nohup +iptables $(1)
endef

Package/luci-app-v2ray = $(call Package/luci-app-v2ray/Default,+ipset)

define Package/luci-app-v2ray/description
	LuCI Support for v2ray-core.
endef

define Build/Prepare
	$(foreach po,$(wildcard ${CURDIR}/files/luci/i18n/*.po), \
		po2lmo $(po) $(PKG_BUILD_DIR)/$(patsubst %.po,%.lmo,$(notdir $(po)));)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/luci-app-v2ray/postinst
#!/bin/sh
if [[ -z "$${IPKG_INSTROOT}" ]]; then
	if [[ -f /etc/uci-defaults/luci-v2ray ]]; then
		( . /etc/uci-defaults/luci-v2ray ) && \
		rm -f /etc/uci-defaults/luci-v2ray
	fi
	rm -rf /tmp/luci-indexcache /tmp/luci-modulecache
fi
exit 0
endef

define Package/luci-app-v2ray/conffiles
/etc/config/v2ray
endef

define Package/luci-app-v2ray/install
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/i18n
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/v2ray.*.lmo $(1)/usr/lib/lua/luci/i18n/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DATA) ./files/luci/controller/*.lua $(1)/usr/lib/lua/luci/controller/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/v2ray
	$(INSTALL_DATA) ./files/luci/model/cbi/v2ray/*.lua $(1)/usr/lib/lua/luci/model/cbi/v2ray/
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/view/v2ray
	$(INSTALL_DATA) ./files/luci/view/v2ray/*.htm $(1)/usr/lib/lua/luci/view/v2ray/
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/root/etc/config/v2ray $(1)/etc/config/v2ray
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/root/etc/init.d/v2ray $(1)/etc/init.d/v2ray
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/root/etc/uci-defaults/luci-v2ray $(1)/etc/uci-defaults/luci-v2ray
	$(INSTALL_DIR) $(1)/etc/v2ray
	$(INSTALL_BIN) ./files/root/etc/v2ray/* $(1)/etc/v2ray/
endef

$(eval $(call BuildPackage,luci-app-v2ray))
