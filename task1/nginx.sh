#!/usr/bin/bash

NAME=lazarevva
GROUP=628
EMAIL=vlazarew@ispras.ru

VALID_NAME=ocsp.valid.$NAME.ru
REVOKED_NAME=ocsp.revoked.$NAME.ru
OCSP_NAME=ocsp.$NAME.ru

CURR_DIR=$(pwd)

sudo mkdir -p /var/www/$VALID_NAME/html
sudo mkdir -p /var/www/$REVOKED_NAME/html

sudo chown -R $USER:$USER /var/www/$VALID_NAME/html
sudo chown -R $USER:$USER /var/www/$REVOKED_NAME/html

sudo chmod -R 755 /var/www

# create valid html page
echo "<html>" > /var/www/$VALID_NAME/html/index.html
echo "    <head><title>It's working pretty good. Like, subscribe and kolokol'chik</title></head>" >> /var/www/$VALID_NAME/html/index.html
echo "    <body><h3>It's working pretty good. Like, subscribe and kolokol'chik</h3></body>" >> /var/www/$VALID_NAME/html/index.html
echo "</html>" >> /var/www/$VALID_NAME/html/index.html


# create revoked html page
echo "<html>" > /var/www/$REVOKED_NAME/html/index.html
echo "    <head><title>It's revoked. Press F</title></head>" >> /var/www/$REVOKED_NAME/html/index.html
echo "    <body><h3>It's revoked. Press F</h3></body>" >> /var/www/$REVOKED_NAME/html/index.html
echo "</html>" >> /var/www/$REVOKED_NAME/html/index.html

echo "server {" > valid_site.txt
echo "        listen 80;" >> valid_site.txt
echo "        listen [::]:80;" >> valid_site.txt
echo "" >> valid_site.txt
echo "	listen 443 ssl;" >> valid_site.txt
echo "	listen [::]:443 ssl;" >> valid_site.txt
echo "" >> valid_site.txt
echo "	ssl_certificate $CURR_DIR/task1.3/$NAME-$GROUP-ocsp-valid-chain.crt;" >> valid_site.txt
echo "	ssl_certificate_key $CURR_DIR/task1.3/$NAME-$GROUP-ocsp-valid.key;" >> valid_site.txt
echo "" >> valid_site.txt
echo "        root /var/www/$VALID_NAME/html;" >> valid_site.txt
echo "        index index.html index.htm index.nginx-debian.html;" >> valid_site.txt
echo "" >> valid_site.txt
echo "        server_name $VALID_NAME www.$VALID_NAME;" >> valid_site.txt
echo "" >> valid_site.txt
echo "        location / {" >> valid_site.txt
echo "                try_files \$uri \$uri/ =404;" >> valid_site.txt
echo "        }" >> valid_site.txt
echo "}" >> valid_site.txt

echo "server {" > revoked_site.txt
echo "        listen 80;" >> revoked_site.txt
echo "        listen [::]:80;" >> revoked_site.txt
echo "" >> revoked_site.txt
echo "	listen 443 ssl;" >> revoked_site.txt
echo "	listen [::]:443 ssl;" >> revoked_site.txt
echo "" >> revoked_site.txt
echo "	ssl_certificate $CURR_DIR/task1.3/$NAME-$GROUP-ocsp-revoked-chain.crt;" >> revoked_site.txt
echo "	ssl_certificate_key $CURR_DIR/task1.3/$NAME-$GROUP-ocsp-revoked.key;" >> revoked_site.txt
echo "" >> revoked_site.txt
echo "        root /var/www/$REVOKED_NAME/html;" >> revoked_site.txt
echo "        index index.html index.htm index.nginx-debian.html;" >> revoked_site.txt
echo "" >> revoked_site.txt
echo "        server_name $REVOKED_NAME www.$REVOKED_NAME;" >> revoked_site.txt
echo "" >> revoked_site.txt
echo "        location / {" >> revoked_site.txt
echo "                try_files \$uri \$uri/ =404;" >> revoked_site.txt
echo "        }" >> revoked_site.txt
echo "}" >> revoked_site.txt
echo "" >> revoked_site.txt
echo "server {" >> revoked_site.txt
echo "	listen 127.0.0.1:80;" >> revoked_site.txt
echo "" >> revoked_site.txt
echo "	server_name $OCSP_NAME www.$OCSP_NAME;" >> revoked_site.txt
echo "" >> revoked_site.txt
echo "	location / {" >> revoked_site.txt
echo "	    proxy_pass http://127.0.0.1:2560;" >> revoked_site.txt
echo "	}" >> revoked_site.txt
echo "}" >> revoked_site.txt

cp valid_site.txt /etc/nginx/sites-available/$VALID_NAME
cp revoked_site.txt /etc/nginx/sites-available/$REVOKED_NAME

sudo ln -s /etc/nginx/sites-available/$VALID_NAME /etc/nginx/sites-enabled/
sudo ln -s /etc/nginx/sites-available/$REVOKED_NAME /etc/nginx/sites-enabled/

sudo nginx -t
sudo systemctl restart nginx


# write something:
echo "" >> /etc/hosts
echo "127.0.0.100     $VALID_NAME" >> /etc/hosts
echo "127.0.0.200     $REVOKED_NAME" >> /etc/hosts
echo "127.0.0.1       $OCSP_NAME" >> /etc/hosts