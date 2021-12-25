echo "acl localnet src 0.0.0.1-0.255.255.255	# RFC 1122 \"this\" network (LAN)" > part2.conf
echo "acl localnet src 10.0.0.0/8		# RFC 1918 local private network (LAN)" >> part2.conf
echo "acl localnet src 100.64.0.0/10		# RFC 6598 shared address space (CGN)" >> part2.conf
echo "acl localnet src 169.254.0.0/16 	# RFC 3927 link-local (directly plugged) machines" >> part2.conf
echo "acl localnet src 172.16.0.0/12		# RFC 1918 local private network (LAN)" >> part2.conf
echo "acl localnet src 192.168.0.0/16		# RFC 1918 local private network (LAN)" >> part2.conf
echo "acl localnet src fc00::/7       	# RFC 4193 local private network range" >> part2.conf
echo "acl localnet src fe80::/10      	# RFC 4291 link-local (directly plugged) machines" >> part2.conf
echo "acl SSL_ports port 443" >> part2.conf
echo "acl Safe_ports port 80		# http" >> part2.conf
echo "acl Safe_ports port 21		# ftp" >> part2.conf
echo "acl Safe_ports port 443		# https" >> part2.conf
echo "acl Safe_ports port 70		# gopher" >> part2.conf
echo "acl Safe_ports port 210		# wais" >> part2.conf
echo "acl Safe_ports port 1025-65535	# unregistered ports" >> part2.conf
echo "acl Safe_ports port 280		# http-mgmt" >> part2.conf
echo "acl Safe_ports port 488		# gss-http" >> part2.conf
echo "acl Safe_ports port 591		# filemaker" >> part2.conf
echo "acl Safe_ports port 777		# multiling http" >> part2.conf
echo "acl CONNECT method CONNECT" >> part2.conf
echo "" >> part2.conf
echo "http_access deny !Safe_ports" >> part2.conf
echo "http_access deny CONNECT !SSL_ports" >> part2.conf
echo "http_access allow localhost manager" >> part2.conf
echo "http_access deny manager" >> part2.conf
echo "" >> part2.conf
echo "include /etc/squid/conf.d/*" >> part2.conf
echo "" >> part2.conf
echo "request_header_access User-Agent deny all" >> part2.conf
echo "request_header_replace User-Agent $NAME" >> part2.conf
echo "http_access allow localhost" >> part2.conf
echo "" >> part2.conf
echo "http_port 3128" >> part2.conf
echo "" >> part2.conf
echo "coredump_dir /var/spool/squid" >> part2.conf
echo "" >> part2.conf
echo "refresh_pattern ^ftp:		1440	20%	10080" >> part2.conf
echo "refresh_pattern ^gopher:	1440	0%	1440" >> part2.conf
echo "refresh_pattern -i (/cgi-bin/|\?) 0	0%	0" >> part2.conf
echo "refresh_pattern \/(Packages|Sources)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims" >> part2.conf
echo "refresh_pattern \/Release(|\.gpg)$ 0 0% 0 refresh-ims" >> part2.conf
echo "refresh_pattern \/InRelease$ 0 0% 0 refresh-ims" >> part2.conf
echo "refresh_pattern \/(Translation-.*)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims" >> part2.conf
echo "refresh_pattern .		0	20%	4320" >> part2.conf