echo "acl localnet src 0.0.0.1-0.255.255.255	# RFC 1122 \"this\" network (LAN)" > part1.conf
echo "acl localnet src 10.0.0.0/8		# RFC 1918 local private network (LAN)" >> part1.conf
echo "acl localnet src 100.64.0.0/10		# RFC 6598 shared address space (CGN)" >> part1.conf
echo "acl localnet src 169.254.0.0/16 	# RFC 3927 link-local (directly plugged) machines" >> part1.conf
echo "acl localnet src 172.16.0.0/12		# RFC 1918 local private network (LAN)" >> part1.conf
echo "acl localnet src 192.168.0.0/16		# RFC 1918 local private network (LAN)" >> part1.conf
echo "acl localnet src fc00::/7       	# RFC 4193 local private network range" >> part1.conf
echo "acl localnet src fe80::/10      	# RFC 4291 link-local (directly plugged) machines" >> part1.conf
echo "acl SSL_ports port 443" >> part1.conf
echo "acl Safe_ports port 80		# http" >> part1.conf
echo "acl Safe_ports port 21		# ftp" >> part1.conf
echo "acl Safe_ports port 443		# https" >> part1.conf
echo "acl Safe_ports port 70		# gopher" >> part1.conf
echo "acl Safe_ports port 210		# wais" >> part1.conf
echo "acl Safe_ports port 1025-65535	# unregistered ports" >> part1.conf
echo "acl Safe_ports port 280		# http-mgmt" >> part1.conf
echo "acl Safe_ports port 488		# gss-http" >> part1.conf
echo "acl Safe_ports port 591		# filemaker" >> part1.conf
echo "acl Safe_ports port 777		# multiling http" >> part1.conf
echo "acl CONNECT method CONNECT" >> part1.conf
echo "" >> part1.conf
echo "http_access deny !Safe_ports" >> part1.conf
echo "http_access deny CONNECT !SSL_ports" >> part1.conf
echo "http_access allow localhost manager" >> part1.conf
echo "http_access deny manager" >> part1.conf
echo "" >> part1.conf
echo "include /etc/squid/conf.d/*" >> part1.conf
echo "" >> part1.conf
echo "acl blocksites dstdomain .ident.me" >> part1.conf
echo "http_access deny blocksites" >> part1.conf
echo "http_access allow localhost" >> part1.conf
echo "" >> part1.conf
echo "http_port 3128" >> part1.conf
echo "" >> part1.conf
echo "coredump_dir /var/spool/squid" >> part1.conf
echo "" >> part1.conf
echo "refresh_pattern ^ftp:		1440	20%	10080" >> part1.conf
echo "refresh_pattern ^gopher:	1440	0%	1440" >> part1.conf
echo "refresh_pattern -i (/cgi-bin/|\?) 0	0%	0" >> part1.conf
echo "refresh_pattern \/(Packages|Sources)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims" >> part1.conf
echo "refresh_pattern \/Release(|\.gpg)$ 0 0% 0 refresh-ims" >> part1.conf
echo "refresh_pattern \/InRelease$ 0 0% 0 refresh-ims" >> part1.conf
echo "refresh_pattern \/(Translation-.*)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims" >> part1.conf
echo "refresh_pattern .		0	20%	4320" >> part1.conf