echo "acl localnet src 0.0.0.1-0.255.255.255	# RFC 1122 \"this\" network (LAN)" > $NAME_GROUP-bump.conf
echo "acl localnet src 10.0.0.0/8		# RFC 1918 local private network (LAN)" >> $NAME_GROUP-bump.conf
echo "acl localnet src 100.64.0.0/10		# RFC 6598 shared address space (CGN)" >> $NAME_GROUP-bump.conf
echo "acl localnet src 169.254.0.0/16 	# RFC 3927 link-local (directly plugged) machines" >> $NAME_GROUP-bump.conf
echo "acl localnet src 172.16.0.0/12		# RFC 1918 local private network (LAN)" >> $NAME_GROUP-bump.conf
echo "acl localnet src 192.168.0.0/16		# RFC 1918 local private network (LAN)" >> $NAME_GROUP-bump.conf
echo "acl localnet src fc00::/7       	# RFC 4193 local private network range" >> $NAME_GROUP-bump.conf
echo "acl localnet src fe80::/10      	# RFC 4291 link-local (directly plugged) machines" >> $NAME_GROUP-bump.conf
echo "acl SSL_ports port 443" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 80		# http" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 21		# ftp" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 443		# https" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 70		# gopher" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 210		# wais" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 1025-65535	# unregistered ports" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 280		# http-mgmt" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 488		# gss-http" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 591		# filemaker" >> $NAME_GROUP-bump.conf
echo "acl Safe_ports port 777		# multiling http" >> $NAME_GROUP-bump.conf
echo "acl CONNECT method CONNECT" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "http_access deny !Safe_ports" >> $NAME_GROUP-bump.conf
echo "http_access deny CONNECT !SSL_ports" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "http_access allow localhost manager" >> $NAME_GROUP-bump.conf
echo "http_access deny manager" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "include /etc/squid/conf.d/*" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "http_access allow localhost" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "http_access deny all" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "http_port 3128 ssl-bump cert=$(pwd)/$CHAIN_NAME.crt key=$(pwd)/$BUMP_NAME.key generate-host-certificates=on" >> $NAME_GROUP-bump.conf
echo "sslcrtd_program /usr/lib/squid/security_file_certgen -s /var/lib/ssl_db -M 4MB" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "acl bad_urls ssl::server_name ident.me" >> $NAME_GROUP-bump.conf
echo "acl good_urls ssl::server_name httpbin.org" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "http_access allow good_urls" >> $NAME_GROUP-bump.conf
echo "http_access allow bad_urls" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "acl step1 at_step SslBump1" >> $NAME_GROUP-bump.conf
echo "ssl_bump peek step1" >> $NAME_GROUP-bump.conf
echo "ssl_bump bump good_urls" >> $NAME_GROUP-bump.conf
echo "ssl_bump splice good_urls" >> $NAME_GROUP-bump.conf
echo "ssl_bump terminate all" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "coredump_dir /var/spool/squid" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "refresh_pattern ^ftp:		1440	20%	10080" >> $NAME_GROUP-bump.conf
echo "refresh_pattern ^gopher:	1440	0%	1440" >> $NAME_GROUP-bump.conf
echo "refresh_pattern -i (/cgi-bin/|\?) 0	0%	0" >> $NAME_GROUP-bump.conf
echo "refresh_pattern \/(Packages|Sources)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims" >> $NAME_GROUP-bump.conf
echo "refresh_pattern \/Release(|\.gpg)$ 0 0% 0 refresh-ims" >> $NAME_GROUP-bump.conf
echo "refresh_pattern \/InRelease$ 0 0% 0 refresh-ims" >> $NAME_GROUP-bump.conf
echo "refresh_pattern \/(Translation-.*)(|\.bz2|\.gz|\.xz)$ 0 0% 0 refresh-ims" >> $NAME_GROUP-bump.conf
echo "" >> $NAME_GROUP-bump.conf
echo "refresh_pattern .		0	20%	4320" >> $NAME_GROUP-bump.conf