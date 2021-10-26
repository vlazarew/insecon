#!/usr/bin/bash
NAME=lazarevva
GROUP=628
EMAIL=vlazarew@ispras.ru


ROOT_CA_NAME=$NAME-$GROUP-ca
INTR_CA_NAME=$NAME-$GROUP-intr
BASIC_NAME=$NAME-$GROUP-basic

mkdir task1.1
cd task1.1


# САМОПОДПИСНОЙ

# Генерация ключевой пары RSA 4096 бит, зашифрованной AES 256 бит:
openssl genrsa -aes256 -passout pass:$NAME -out $ROOT_CA_NAME.key 4096

# Выпуск сертификата на 5 лет:
openssl req -x509 \
	-passin pass:$NAME \
	-new \
	-days 1825 \
	-key $ROOT_CA_NAME.key \
	-out $ROOT_CA_NAME.crt \
	-subj "/C=RU/ST=Moscow/L=Moscow/O=$NAME/OU=$NAME P1/CN=$NAME CA/emailAddress=$EMAIL" \
	-addext "keyUsage = critical, digitalSignature, keyCertSign, cRLSign"

echo "ROOT SERTIFICATE:"
# Печать сертификата
openssl x509 -text -in $ROOT_CA_NAME.crt


# ПРОМЕЖУТОЧНЫЙ

echo "basicConstraints = critical,CA:true,pathlen:0" > intr.txt
echo "keyUsage = critical, digitalSignature, keyCertSign, cRLSign" >> intr.txt
# Ключевая пара для промежуточного сертификата
openssl genrsa -aes256 -passout pass:$NAME -out $INTR_CA_NAME.key 4096

# Выпуск промежуточного сертификата:
openssl req \
	-passin pass:$NAME \
	-new \
	-key $INTR_CA_NAME.key \
	-out $INTR_CA_NAME.csr \
	-subj "/C=RU/ST=Moscow/L=Moscow/O=$NAME/OU=$NAME P1/CN=$NAME Intermediate CA/emailAddress=$EMAIL"

# Промежуточный сертификат подписываем корневым
openssl x509 -req \
 	-passin pass:$NAME \
	-days 365 \
	-CA $ROOT_CA_NAME.crt \
	-CAkey $ROOT_CA_NAME.key \
	-CAcreateserial -CAserial serial \
	-in $INTR_CA_NAME.csr -out $INTR_CA_NAME.crt \
	-extfile intr.txt

echo "INTR SERTIFICATE:"
openssl x509 -text -in $INTR_CA_NAME.crt


# basic
echo "basicConstraints = CA:false" > basic.txt
echo "keyUsage = critical, digitalSignature" >> basic.txt
echo "extendedKeyUsage = critical,serverAuth,clientAuth" >> basic.txt
echo "subjectAltName = @alt_names" >> basic.txt
echo "" >> basic.txt
echo "[ alt_names ]" >> basic.txt
echo "DNS.0 = basic.$NAME.ru" >> basic.txt
echo "DNS.1 = basic.$NAME.com" >> basic.txt

# Ключ для базового сертификата
openssl genrsa -out $BASIC_NAME.key 2048
# Генерация базового сертификата
openssl req \
	-passin pass:$NAME \
	-new \
	-key $BASIC_NAME.key \
	-out $BASIC_NAME.csr \
	-subj "/C=RU/ST=Moscow/L=Moscow/O=$NAME/OU=$NAME P1/CN=$NAME Basic/emailAddress=$EMAIL"

# Подписываем базовый сертификат
openssl x509 -req \
	-passin pass:$NAME \
	-days 90 \
	-CA $INTR_CA_NAME.crt \
	-CAkey $INTR_CA_NAME.key \
	-CAcreateserial -CAserial serial \
	-in $BASIC_NAME.csr -out $BASIC_NAME.crt \
	-extfile basic.txt

echo "BASIC SERTIFICATE:"
openssl x509 -text -in $BASIC_NAME.crt

zip $NAME-$GROUP-p1_1.zip *.key *.crt