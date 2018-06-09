This is an OpenWrt package feed containing custom packages for Meta
Mesh OpenWRT firmware, more info https://metamesh.org .

To use these packages, add the following line to the feeds.conf
in the OpenWrt buildroot:

  src-git metamesh https://github.com/wasabinet/metamesh-packages.git
  
Update the feed:

  ./scripts/feeds update metamesh
  
Activate the feed's packages:

  ./scripts/feeds install -a -p metamesh
  
The metamesh packages should now appear in menuconfig.
