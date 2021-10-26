#!/usr/bin/bash

NAME=lazarevva
GROUP=628
EMAIL=vlazarew@ispras.ru

ROOT_CA_NAME=$NAME-$GROUP-ca
INTR_CA_NAME=$NAME-$GROUP-intr
VALID_NAME=$NAME-$GROUP-crl-valid
REVOKED_NAME=$NAME-$GROUP-crl-revoked
CRL_NAME=$NAME-$GROUP.crl
CHAIN_NAME=$NAME-$GROUP-chain.crt

mkdir task1.2
# Копируем промежуточные и корневые сертификаты и ключи из первой таски
cp task1.1/$INTR_CA_NAME.key task1.2/$INTR_CA_NAME.key
cp task1.1/$INTR_CA_NAME.crt task1.2/$INTR_CA_NAME.crt
cp task1.1/$ROOT_CA_NAME.key task1.2/$ROOT_CA_NAME.key
cp task1.1/$ROOT_CA_NAME.crt task1.2/$ROOT_CA_NAME.crt
cd task1.2

# valid
echo "basicConstraints = CA:false" > valid.txt
echo "keyUsage = critical, digitalSignature" >> valid.txt
echo "extendedKeyUsage = critical,serverAuth,clientAuth" >> valid.txt
echo "subjectAltName = DNS:crl.valid.$NAME.ru" >> valid.txt
echo "crlDistributionPoints = URI:http://crl.$NAME.ru" >> valid.txt

# Ключ для валидного сертификата
openssl genrsa -out $VALID_NAME.key 2048
# Генерация валидного сертификата
openssl req -new -key $VALID_NAME.key -out $VALID_NAME.csr \
	-subj "/C=RU/ST=Moscow/L=Moscow/O=$NAME/OU=$NAME P2/CN=$NAME CRL Valid/emailAddress=$EMAIL"

# Подписываем новый сертификат промежуточным
openssl x509 -passin pass:$NAME -req \
	-days 90 \
	-CA $INTR_CA_NAME.crt \
	-CAkey $INTR_CA_NAME.key \
	-CAcreateserial \
	-CAserial serial \
	-in $VALID_NAME.csr -out $VALID_NAME.crt \
	-extfile valid.txt

echo "CRL VALID SERTIFICATE:"
openssl x509 -text -in $VALID_NAME.crt


# revoked
echo "basicConstraints = CA:false" > revoked.txt
echo "keyUsage = critical, digitalSignature" >> revoked.txt
echo "extendedKeyUsage = critical,serverAuth,clientAuth" >> revoked.txt
echo "subjectAltName = DNS:crl.revoked.$NAME.ru" >> revoked.txt
echo "crlDistributionPoints = URI:http://crl.$NAME.ru" >> revoked.txt

# Генерация ключа для отозванного сертификата
openssl genrsa -out $REVOKED_NAME.key 2048
# Генерация сертификата
openssl req -new -key $REVOKED_NAME.key -out $REVOKED_NAME.csr \
	-subj "/C=RU/ST=Moscow/L=Moscow/O=$NAME/OU=$NAME P2/CN=$NAME CRL Revoked/emailAddress=$EMAIL"

# Подписываем сертификат, который будем отзывать
openssl x509 -passin pass:$NAME -req \
	-days 90 \
	-CA $INTR_CA_NAME.crt \
	-CAkey $INTR_CA_NAME.key \
	-CAcreateserial \
	-CAserial serial \
	-in $REVOKED_NAME.csr -out $REVOKED_NAME.crt \
	-extfile revoked.txt

echo "CRL REVOKED SERTIFICATE:"
openssl x509 -text -in $REVOKED_NAME.crt


# make
echo "[ ca ]" > p2.conf
echo "default_ca	= CA_default		# The default ca section" >> p2.conf
echo "" >> p2.conf
echo "[ CA_default ]" >> p2.conf
echo "database = index.txt" >> p2.conf
echo "crlnumber = crl_number" >> p2.conf
echo "serial = serial" >> p2.conf
echo "crl_extensions = crl_ext" >> p2.conf
echo "private_key = $INTR_CA_NAME.key" >> p2.conf
echo "certificate = $INTR_CA_NAME.crt" >> p2.conf
echo "" >> p2.conf
echo "default_days	= 365			# how long to certify for" >> p2.conf
echo "default_crl_days= 30			# how long before next CRL" >> p2.conf
echo "default_md	= default		# use public key default MD" >> p2.conf
echo "preserve	= no			# keep passed DN ordering" >> p2.conf
echo "crlDistributionPoints = URI:http://crl.$NAME.ru" >> p2.conf
echo "" >> p2.conf
echo "" >> p2.conf
echo "[ crl_ext ]" >> p2.conf
echo "authorityKeyIdentifier=keyid" >> p2.conf

# revoke certificate
rm -rf index.txt
touch index.txt
echo 00 > crl_number

openssl ca -passin pass:$NAME -config p2.conf -revoke $REVOKED_NAME.crt
openssl ca -passin pass:$NAME -gencrl -config p2.conf -out $CRL_NAME
echo "CREATED CRL LIST AFTER REVOKE:"
openssl crl -text -in $CRL_NAME

cat $ROOT_CA_NAME.crt $INTR_CA_NAME.crt > $CHAIN_NAME

openssl verify -crl_check -CRLfile $CRL_NAME -CAfile $CHAIN_NAME $VALID_NAME.crt
openssl verify -crl_check -CRLfile $CRL_NAME -CAfile $CHAIN_NAME $REVOKED_NAME.crt

zip $NAME-$GROUP-p1_2.zip $VALID_NAME.key $REVOKED_NAME.key $VALID_NAME.crt $REVOKED_NAME.crt $CHAIN_NAME $CRL_NAME
