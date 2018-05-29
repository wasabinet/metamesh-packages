#
## Copyright (C) 2018 metamesh/pittmesh
#
##

include $(TOPDIR)/rules.mk

PKG_NAME:=pittmesh-autoconf
PKG_VERSION:=0.2
PKG_LICENSE:=GPL-3.0+
PKG_RELEASE=1
PKG_MAINTAINER:=Justin Goetz <justin.goetz@metamesh.org>

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

#pittmesh_platform=glinet-ar150
#pittmesh_type=generic
pittmesh_platform=ar150
pittmesh_type=DHCP-AP-Gateway
script_name=NewportMeshConfigCustom.sh

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk


define Package/pittmesh-autoconf
  SECTION:=Utilities
  CATEGORY:=Utilities
  TITLE:=auto-configuration utility used for pittmesh
  DEPENDS:=+olsrd +olsrd-mod-jsoninfo +olsrd-mod-mdns +dropbear +snmpd +uhttpd
  Maintainer:=$(PKG_MAINTAINER)
endef

define Package/$(PKG_NAME)/description
  A suite of files making mesh networking and management easier - pittmesh
endef

define Build/Compile/Default
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME)/files/mm-mac2ipv4.sh $(1)/usr/bin/mm-mac2ipv4.sh
#	$(CP) $(PKG_BUILD_DIR)/$(PKG_NAME)/files/$(pittmesh_platform)/$(pittmesh_type) $(1)/etc/init.d/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(PKG_NAME)/files/$(pittmesh_platform)/$(pittmesh_type)/$(script_name) $(1)/usr/bin/$(script_name)
endef

$(eval $(call Buildpackage,$(PKG_NAME)))
