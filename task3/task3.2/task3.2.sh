#!/usr/bin/bash

export NAME=lazarevva
export GROUP=628
export EMAIL=vlazarew@ispras.ru

export NAME_GROUP=$NAME-$GROUP
export ROOT_CA_NAME=$NAME_GROUP-ca
export BUMP_NAME=$NAME_GROUP-bump
export CHAIN_NAME=$NAME_GROUP-chain

# Генерация сертификата
echo "basicConstraints = critical,CA:true,pathlen:0" > bump_config.txt
echo "keyUsage = critical, digitalSignature, keyCertSign, cRLSign" >> bump_config.txt

openssl genrsa -out $BUMP_NAME.key 4096
openssl req \
	-passin pass:$NAME \
	-new \
	-key $BUMP_NAME.key \
	-out $BUMP_NAME.csr \
	-subj "/C=RU/ST=Moscow/L=Moscow/O=$NAME/OU=$NAME P3/CN=$NAME Squid CA/emailAddress=$EMAIL"

openssl x509 -req \
	-passin pass:$NAME \
	-days 365 \
	-CA $ROOT_CA_NAME.crt \
	-CAkey $ROOT_CA_NAME.key \
	-CAcreateserial -CAserial serial \
	-in $BUMP_NAME.csr -out $BUMP_NAME.crt \
	-extfile bump_config.txt

echo "BUMP CERTIFICATE:"
openssl x509 -text -in $BUMP_NAME.crt
openssl verify -CAfile $ROOT_CA_NAME.crt $BUMP_NAME.crt

rm serial $BUMP_NAME.csr bump_config.txt

# Создание цепочки для squid'а
cat $BUMP_NAME.crt $ROOT_CA_NAME.crt > $CHAIN_NAME.crt

# *********************** ВЫПОЛНЕНИЕ ACL ЧАСТИ *********************** #
./make_acl.sh
sudo cp $NAME_GROUP-acl.conf /etc/squid/squid.conf

# перезапуск squid:
sudo service squid restart
sudo service squid status

read -p "Run 'sudo wireshark' and listen 'any' interface, filter by 'tcp', then press 'y': " confirm && [[ $confirm == [yY] ]] || exit 1

# GET-запросы к нужным ресурсам
export SSLKEYLOGFILE=$NAME_GROUP-acl.log
curl https://ident.me -x localhost:3128 -A "$NAME"
curl https://httpbin.org/get?bio=$NAME -k -x localhost:3128

read -p "Save wireshark capture to $NAME_GROUP-acl.pcapng, then press 'y': " confirm && [[ $confirm == [yY] ]] || exit 1

# *********************** ВЫПОЛНЕНИЕ BUMP ЧАСТИ *********************** #
./make_bump.sh
sudo cp $NAME_GROUP-bump.conf /etc/squid/squid.conf

# перезапуск squid:
sudo service squid restart
sudo service squid status

read -p "Run 'sudo wireshark' and listen 'any' interface, filter by 'tcp', then press 'y': " confirm && [[ $confirm == [yY] ]] || exit 1

# GET-запросы к нужным ресурсам для BUMP части
export SSLKEYLOGFILE=$NAME_GROUP-bump.log
curl https://httpbin.org/get?bio=$NAME -k -x localhost:3128

read -p "Save wireshark capture to $NAME_GROUP-bump.pcapng, then press 'y': " confirm && [[ $confirm == [yY] ]] || exit 1

# итоговая архивация
sudo zip $NAME_GROUP-p3_2.zip $NAME_GROUP-acl.pcapng $NAME_GROUP-acl.log $NAME_GROUP-acl.conf $NAME_GROUP-bump.pcapng $NAME_GROUP-bump.log $NAME_GROUP-bump.conf $BUMP_NAME.crt $BUMP_NAME.key $ROOT_CA_NAME.crt