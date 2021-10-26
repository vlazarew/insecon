#!/usr/bin/bash

NAME=lazarevva
GROUP=628
EMAIL=vlazarew@ispras.ru

ROOT_CA_NAME=$NAME-$GROUP-ca
INTR_CA_NAME=$NAME-$GROUP-intr
VALID_NAME=$NAME-$GROUP-ocsp-valid
REVOKED_NAME=$NAME-$GROUP-ocsp-revoked
OCSP_NAME=$NAME-$GROUP-ocsp-resp
CHAIN_NAME=../task1.2/$NAME-$GROUP-chain.crt
OCSP_CHAIN_NAME=$NAME-$GROUP-chain.crt

# mkdir task1.3
# cp task1.1/$INTR_CA_NAME.key task1.3/$INTR_CA_NAME.key
# cp task1.1/$INTR_CA_NAME.crt task1.3/$INTR_CA_NAME.crt
# cp task1.1/$ROOT_CA_NAME.key task1.3/$ROOT_CA_NAME.key
# cp task1.1/$ROOT_CA_NAME.crt task1.3/$ROOT_CA_NAME.crt
# cd task1.3

# # valid
# echo "basicConstraints = CA:false" > valid.txt
# echo "keyUsage = critical, digitalSignature" >> valid.txt
# echo "extendedKeyUsage = critical,serverAuth,clientAuth" >> valid.txt
# echo "subjectAltName = DNS:ocsp.valid.$NAME.ru" >> valid.txt
# echo "authorityInfoAccess = OCSP;URI:http://ocsp.$NAME.ru" >> valid.txt

# openssl genrsa -out $VALID_NAME.key 2048
# openssl req -new -key $VALID_NAME.key -out $VALID_NAME.csr \
# 	-subj "/C=RU/ST=Moscow/L=Moscow/O=$NAME/OU=$NAME P3/CN=$NAME OCSP Valid/emailAddress=$EMAIL"
# openssl x509 -passin pass:$NAME -req \
# 	-days 90 \
# 	-CA $INTR_CA_NAME.crt \
# 	-CAkey $INTR_CA_NAME.key \
# 	-CAcreateserial \
# 	-CAserial serial \
# 	-in $VALID_NAME.csr -out $VALID_NAME.crt \
# 	-extfile valid.txt

# echo "VALID SERTIFICATE"
# openssl x509 -text -in $VALID_NAME.crt


# # revoked
# echo "basicConstraints = CA:false" > revoked.txt
# echo "keyUsage = critical, digitalSignature" >> revoked.txt
# echo "extendedKeyUsage = critical,serverAuth,clientAuth" >> revoked.txt
# echo "subjectAltName = DNS:ocsp.revoked.$NAME.ru" >> revoked.txt
# echo "authorityInfoAccess = OCSP;URI:http://ocsp.$NAME.ru" >> revoked.txt

# openssl genrsa -out $REVOKED_NAME.key 2048
# openssl req -new -key $REVOKED_NAME.key -out $REVOKED_NAME.csr \
# 	-subj "/C=RU/ST=Moscow/L=Moscow/O=$NAME/OU=$NAME P3/CN=$NAME OCSP Revoked/emailAddress=$EMAIL"
# openssl x509 -passin pass:$NAME -req \
# 	-days 90 \
# 	-CA $INTR_CA_NAME.crt \
# 	-CAkey $INTR_CA_NAME.key \
# 	-CAcreateserial \
# 	-CAserial serial \
# 	-in $REVOKED_NAME.csr -out $REVOKED_NAME.crt \
# 	-extfile revoked.txt
# echo "REVOKED SERTIFICATE"
# openssl x509 -text -in $REVOKED_NAME.crt


# # ocsp
# echo "basicConstraints = CA:false" > ocsp.txt
# echo "keyUsage = critical, digitalSignature" >> ocsp.txt
# echo "extendedKeyUsage = OCSPSigning" >> ocsp.txt

# openssl genrsa -aes256 -passout pass:$NAME -out $OCSP_NAME.key 4096
# openssl req -new -key $OCSP_NAME.key -passin pass:$NAME -out $OCSP_NAME.csr \
# 	-subj "/C=RU/ST=Moscow/L=Moscow/O=$NAME/OU=$NAME P3/CN=$NAME OCSP Responder/emailAddress=$EMAIL"
# openssl x509 -passin pass:$NAME -req \
# 	-days 365 \
# 	-CA $INTR_CA_NAME.crt \
# 	-CAkey $INTR_CA_NAME.key \
# 	-CAcreateserial \
# 	-CAserial serial \
# 	-in $OCSP_NAME.csr -out $OCSP_NAME.crt \
# 	-extfile ocsp.txt
# echo "OCSP RESPONDER SERTIFICATE"
# openssl x509 -text -in $OCSP_NAME.crt


# rm -rf ocsp-index.txt
# touch ocsp-index.txt


# # 
# echo "[ ca ]" > p3.conf
# echo "default_ca	= CA_default		# The default ca section" >> p3.conf
# echo "" >> p3.conf
# echo "[ CA_default ]" >> p3.conf
# echo "database = ocsp-index.txt" >> p3.conf
# echo "private_key = $INTR_CA_NAME.key" >> p3.conf
# echo "certificate = $INTR_CA_NAME.crt" >> p3.conf
# echo "" >> p3.conf
# echo "default_days	= 365			# how long to certify for" >> p3.conf
# echo "default_crl_days= 30			# how long before next CRL" >> p3.conf
# echo "default_md	= default		# use public key default MD" >> p3.conf
# echo "preserve	= no			# keep passed DN ordering" >> p3.conf
# echo "authorityInfoAccess = OCSP;URI:http://ocsp.$NAME.ru" >> p3.conf
# echo "" >> p3.conf

# openssl ca \
# 	-config p3.conf \
# 	-passin pass:$NAME \
# 	-revoke $REVOKED_NAME.crt

# openssl ca \
# 	-config p3.conf \
# 	-passin pass:$NAME \
# 	-valid $VALID_NAME.crt

# # make chain
# cat $OCSP_NAME.crt $CHAIN_NAME > $OCSP_CHAIN_NAME


# # make verification script
# echo "#!/usr/bin/bash" > verify.sh
# echo "" >> verify.sh
# echo "openssl ocsp \\" >> verify.sh
# echo "	-url http://ocsp.$NAME.ru:2560 \\" >> verify.sh
# echo "	-CAfile $CHAIN_NAME \\" >> verify.sh
# echo "	-issuer $INTR_CA_NAME.crt \\" >> verify.sh
# echo "	-cert $REVOKED_NAME.crt" >> verify.sh
# echo "" >> verify.sh
# echo "openssl ocsp \\" >> verify.sh
# echo "	-url http://ocsp.$NAME.ru:2560 \\" >> verify.sh
# echo "	-CAfile $CHAIN_NAME \\" >> verify.sh
# echo "	-issuer $INTR_CA_NAME.crt \\" >> verify.sh
# echo "	-cert $VALID_NAME.crt" >> verify.sh
# chmod +x verify.sh

# cat $VALID_NAME.crt $CHAIN_NAME > ${VALID_NAME}-chain.crt
# cat $REVOKED_NAME.crt $CHAIN_NAME > ${REVOKED_NAME}-chain.crt

# openssl ocsp -port 2560 \
# 	-index ocsp-index.txt \
# 	-CA $CHAIN_NAME \
# 	-rkey $OCSP_NAME.key \
# 	-rsigner $OCSP_NAME.crt


# go to task1.3 and run ./verify.sh
# Example output:
# Response verify OK
# lazarevva-628-ocsp-revoked.crt: revoked
# 	This Update: Oct 21 22:25:29 2021 GMT
# 	Revocation Time: Oct 21 22:25:18 2021 GMT
# Response verify OK
# lazarevva-628-ocsp-valid.crt: good
# 	This Update: Oct 21 22:25:29 2021 GMT

zip $NAME-$GROUP-p1_3.zip \
	$VALID_NAME.key $VALID_NAME.crt $VALID_NAME.log $VALID_NAME.pcapng \
	$REVOKED_NAME.key $REVOKED_NAME.crt $REVOKED_NAME.log $REVOKED_NAME.pcapng \
	$OCSP_NAME.key $OCSP_NAME.crt \
	$OCSP_CHAIN_NAME
