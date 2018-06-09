## Copyright (C) 2018 metamesh/pittmesh
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pittmesh-autoconf
PKG_VERSION:=0.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-3.0+
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

# Custom vars
pittmesh_platform:=glinet-ar150
pittmesh_type:=generic
pittmesh_platform:=ar150
pittmesh_type:=DHCP-AP-Gateway
script_name:=NewportMeshConfigCustom.sh

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

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/pittmesh-autoconf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) ./files/mm-mac2ipv4.sh $(1)/usr/bin/
#	$(CP) ./files/$(pittmesh_platform)/$(pittmesh_type) $(1)/etc/init.d/
	$(CP) ./files/$(pittmesh_platform)/$(pittmesh_type)/$(script_name) $(1)/usr/bin/$(script_name)
endef

$(eval $(call BuildPackage,pittmesh-autoconf))
