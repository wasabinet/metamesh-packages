# This is the first time auto-configuration script for Meta Mesh AP150s.
# Updated for OpenWrt SNAPSHOT circa 18.06

# © 2018 Meta Mesh Wireless Communities. All rights reserved.
# Licensed under the terms of the MIT license.
#
# AUTHORS
# * Justin Goetz
# * Adam Longwill
# * Evie Vanderveer
#
# TODO: This is script isn't idempotent.  Running on existing config messes with
# olsrd and firewall sections.
# TODO: Port this script to use config_get / config_get functions in
# /lib/functions.sh per https://openwrt.org/docs/guide-developer/config-scripting
#
# Changed PITTMESH references to NWM.
#
# This script is launched by our /etc/init.d script, and it runs only if enabled
# in /etc/config/metamesh-autoconf.  Upon successful completion, this script will
# then update /etc/config/metamesh-autoconf to disable itself and then reboot.

firstconfig_enabled=$(uci get metamesh-autoconf.@firstconfig[0].enabled)
[ 1 -eq "$firstconfig_enabled" ] || exit 0

logger MeshFirstConfig.sh deploying configuration

# Update where OpenWRT pulls updates from. - AWAITING NEW RELEASE BEFORE MIRRORING ON OUR SERVER
#rm /etc/opkg/distfeeds.conf
#echo src/gz chaos_calmer_base http://openwrt.metamesh.org/a150/openwrt/ar71xx/clean/1.0/packages/base>> /etc/opkg.conf
#echo src/gz chaos_calmer_luci http://openwrt.metamesh.org/a150/openwrt/ar71xx/clean/1.0/packages/luci>> /etc/opkg.conf
#echo src/gz chaos_calmer_management http://openwrt.metamesh.org/a150/openwrt/ar71xx/clean/1.0/packages/management>> /etc/opkg.conf
#echo src/gz chaos_calmer_packages http://openwrt.metamesh.org/a150/openwrt/ar71xx/clean/1.0/packages/packages>> /etc/opkg.conf
#echo src/gz chaos_calmer_routing http://openwrt.metamesh.org/a150/openwrt/ar71xx/clean/1.0/packages/routing>> /etc/opkg.conf
#echo src/gz chaos_calmer_telephony http://openwrt.metamesh.org/a150/openwrt/ar71xx/clean/1.0/packages/telephony>> /etc/opkg.conf
#echo src/gz pittmesh http://openwrt.metamesh.org/pittmesh>> /etc/opkg.conf

# Get role
firstconfig_role=$(uci get metamesh-autoconf.@firstconfig[0].role)

# Set Hostname
uci set system.@system[0].hostname=ap150-STRING-2401

# Disable the RFC1918 filter in the webserver which would prevent you from accessing 100. mesh nodes.
uci set uhttpd.main.rfc1918_filter=0; uci commit uhttpd

# Restart uhttpd webserver and it will generate a new 1024 bit key.
/etc/init.d/uhttpd restart

# Disable ipv6 dhcp requests because we don't use them and they cause noise.
/etc/init.d/odhcpd disable

# Set the timeserver to a node host on Mount Oliver who has a stratum 0 time server and set logs to go to Meta Mesh.
uci set system.@system[0].timezone=EST5EDT,M3.2.0,M11.1.0
uci set system.@system[0].zonename="America/New York"
uci set system.ntp=timeserver
uci set system.ntp.enabled=1
uci set system.ntp.enable_server=1

uci commit system

# Forward all DNS requests to a public DNS server.
uci delete dhcp.@dnsmasq[0].server
uci add_list dhcp.@dnsmasq[0].server='8.8.8.8'
uci add_list dhcp.@dnsmasq[0].server='8.8.4.4'
uci commit dhcp

ipMESH=$(mm-mac2ipv4.sh $(cat /sys/class/net/eth0/address));
ipLAN=$(echo "10.$(echo $ipMESH|cut -d "." -f 3-4).1");
ipHNA=$(echo "10.$(echo $ipMESH|cut -d "." -f 3-4).0");
ipETHERMESH=100.$(expr $(echo $ipMESH|cut -d "." -f 4) % 64 + 64).$(echo $ipMESH|cut -d "." -f 3).$(echo $ipMESH|cut -d "." -f 2)

# Set up interfaces and use the mm-mac2ipv4 script's conversions as IP addresses.
uci set network.mesh=interface
uci set network.mesh.proto=static
uci set network.mesh.ipaddr=$ipMESH
uci set network.mesh.netmask=255.192.0.0
uci set network.mesh.dns='8.8.8.8 8.8.4.4'

#Set up ethermesh interface
uci set network.ethermesh=interface
uci set network.ethermesh.proto=static
uci set network.ethermesh.ifname=eth0
uci set network.ethermesh.netmask=255.192.0.0
uci set network.ethermesh.dns='8.8.8.8 8.8.4.4'
uci set network.ethermesh.ipaddr=$ipETHERMESH

# Note: because we originally wrote the script for another device, we're calling the wlan variable. on ar150's the wlan and lan are bridged.
uci set network.lan=interface
uci set network.lan.proto=static
uci set network.lan.ipaddr=$ipLAN
uci set network.lan.netmask=255.255.255.0
uci set network.lan._orig_ifname=eth1
uci set network.lan._orig_bridge=true
uci set network.lan.force_link=1
uci set network.lan.bridge=1
uci commit network

# Set DHCP server to give out leases over the bridged wlan and lan interface for 1 hour from 10-253 and force it.
uci set dhcp.lan.start=10
uci set dhcp.lan.limit=253
uci set dhcp.lan.leasetime=1h
uci set dhcp.lan.force=1
uci commit dhcp

# Set up the WiFi. Please change the SSID to NWM-youraddress-2401 for the first device, NWM-youraddress-2402 for the second device and so on. Max TX rate for the ar150 is 18dBm.
uci delete wireless.radio0.disabled
uci set wireless.radio0.txpower=18
uci set wireless.radio0.country=US
uci add wireless wifi-iface
uci set wireless.@wifi-iface[1].device=radio0
uci set wireless.@wifi-iface[1].encryption=none
uci set wireless.@wifi-iface[1].ssid=NWM-Backhaul
uci set wireless.@wifi-iface[1].mode=adhoc
uci set wireless.@wifi-iface[1].network=mesh
uci set wireless.@wifi-iface[0].network='lan'
uci set wireless.@wifi-iface[0].ssid=NWM-NEWNODE-2401
uci set wireless.@wifi-iface[0].disabled=0
uci commit wireless

# Set HNA announcements for the LAN and Internet
# TODO: Problems will running this section repeatedly on existing olsrd config
uci add olsrd Hna4
uci set olsrd.@Hna4[0].netaddr=$ipHNA
uci set olsrd.@Hna4[0].netmask=255.255.255.0

# Only add HNA 0.0.0.0 to gateways
if [ "$firstconfig_role" = 'gateway' ] ; then
    uci add olsrd Hna4
    uci set olsrd.@Hna4[1].netaddr=0.0.0.0
    uci set olsrd.@Hna4[1].netmask=0.0.0.0
fi

uci set olsrd.@Interface[0].ignore=0
uci set olsrd.@Interface[0].Mode=mesh
uci set olsrd.@Interface[0].interface='mesh'
uci add olsrd InterfaceDefaults
uci set olsrd.@InterfaceDefaults[0].Mode=mesh
uci add olsrd Interface
uci set olsrd.@Interface[1].ignore=0
uci set olsrd.@Interface[1].interface=lan
uci set olsrd.@Interface[1].Mode=ether
uci set olsrd.@Interface[1].interface=ethermesh
uci set olsrd.@olsrd[0].LinkQualityAlgorithm=etx_ffeth
uci commit olsrd

# Enable olsrd plugins
if ! [ "$(uci show olsrd|grep olsrd_mdns)" ] ; then
    uci add olsrd LoadPlugin
    uci set olsrd.@LoadPlugin[-1].library=olsrd_mdns.so.1.0.1
    uci set olsrd.@LoadPlugin[-1].ignore=0
    uci commit olsrd
fi
if ! [ "$(uci show olsrd|grep olsrd_jsoninfo)" ] ; then
    uci add olsrd LoadPlugin
    uci set olsrd.@LoadPlugin[-1].library=olsrd_jsoninfo.so.1.1
    uci set olsrd.@LoadPlugin[-1].ignore=0
    uci commit olsrd
fi

# Set iptables rules to allow forwarding between interfaces.
uci set firewall.@defaults[0].forward=ACCEPT
uci set firewall.@zone[1].input=ACCEPT
uci set firewall.@zone[1].forward=ACCEPT
uci add firewall zone
uci set firewall.@zone[2].input=ACCEPT
uci set firewall.@zone[2].forward=ACCEPT
uci set firewall.@zone[2].output=ACCEPT
uci set firewall.@zone[2].name=mesh
uci set firewall.@zone[2].network='ethermesh mesh'
uci add firewall forwarding
uci set firewall.@forwarding[1].dest=mesh
uci set firewall.@forwarding[1].src=lan
uci add firewall forwarding
uci set firewall.@forwarding[2].dest=lan
uci set firewall.@forwarding[2].src=mesh
uci add firewall forwarding
uci set firewall.@forwarding[3].dest=wan
uci set firewall.@forwarding[3].src=mesh
uci add firewall forwarding
uci set firewall.@forwarding[4].dest=lan
uci set firewall.@forwarding[4].src=wan
uci add firewall forwarding
uci set firewall.@forwarding[5].dest=mesh
uci set firewall.@forwarding[5].src=wan
uci commit firewall

# Set custom firewall rules to disallow access to certain IP addresses typically used for private home networks. If you want to share a server on your home network, run OLSR on it and mesh it over ethernet with a 100. address OR connect it directly to a NWM router's LAN port and give it a static address between 10.x.x.2 and 9 (.254 is also available by default)
uci add firewall rule
uci set firewall.@rule[9].dest=wan
uci set firewall.@rule[9].proto=all
uci set firewall.@rule[9].src=lan
uci set firewall.@rule[9].target=DROP
uci set firewall.@rule[9].dest_ip=172.16.0.0/12
uci set firewall.@rule[9].name=Block-LAN-Access
uci add firewall rule
uci set firewall.@rule[10].src=lan
uci set firewall.@rule[10].dest=wan
uci set firewall.@rule[10].proto=all
uci set firewall.@rule[10].dest_ip=192.168.0.0/16
uci set firewall.@rule[10].target=DROP
uci set firewall.@rule[10].name=Block-LAN-Access-1
uci add firewall rule
uci set firewall.@rule[11].enabled=1
uci set firewall.@rule[11].target=DROP
uci set firewall.@rule[11].src=lan
uci set firewall.@rule[11].dest=wan
uci set firewall.@rule[11].proto=all
uci set firewall.@rule[11].dest_ip=10.0.0.0/8
uci set firewall.@rule[11].name=Block-LAN-Access-2
uci commit firewall

# We're done, so disable me from running again
logger "metamesh-autoconfig completed firstconfig, disabling itself"
uci set metamesh-autoconf.@firstconfig[0].enabled=0
uci commit metamesh-autoconf

logger MeshFirstConfig.sh rebooting
reboot
