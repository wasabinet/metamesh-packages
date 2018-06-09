## Copyright (C) 2018 metamesh/pittmesh
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pittmesh-autoconf
PKG_VERSION:=0.2
PKG_RELEASE:=1
PKG_LICENSE:=MIT
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

# Custom vars
pittmesh_platform:=glinet-ar150
pittmesh_type:=generic
pittmesh_platform:=ar150
pittmesh_type:=DHCP-AP-Gateway
script_name:=MeshFirstConfig.sh

include $(INCLUDE_DIR)/package.mk

define Package/pittmesh-autoconf
  SECTION:=metamesh
  CATEGORY:=Metamesh
  TITLE:=auto-configuration utility used for pittmesh
  DEPENDS:=+olsrd +olsrd-mod-jsoninfo +olsrd-mod-mdns +dropbear +snmpd +uhttpd
  MAINTAINER:=Justin Goetz <justin.goetz@metamesh.org>
endef

define Package/pittmesh-autoconf/description
  A suite of files making mesh networking and management easier - pittmesh
endef

define Package/pittmesh-autoconf/conffiles
/etc/config/pittmesh-autoconf
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/pittmesh-autoconf/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) ./files/sbin/mm-mac2ipv4.sh $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/lib/metamesh
	$(INSTALL_BIN) ./files/lib/metamesh/MeshFirstConfig.sh $(1)/lib/metamesh/MeshFirstConfig.sh
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DATA) ./files/pittmesh-autoconf.config $(1)/etc/config/pittmesh-autoconf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/pittmesh-autoconf.init $(1)/etc/init.d/pittmesh-autoconf
endef

$(eval $(call BuildPackage,pittmesh-autoconf))
