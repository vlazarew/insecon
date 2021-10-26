#!/usr/bin/bash

openssl ocsp \
	-url http://ocsp.lazarevva.ru:2560 \
	-CAfile ../task1.2/lazarevva-628-chain.crt \
	-issuer lazarevva-628-intr.crt \
	-cert lazarevva-628-ocsp-revoked.crt

openssl ocsp \
	-url http://ocsp.lazarevva.ru:2560 \
	-CAfile ../task1.2/lazarevva-628-chain.crt \
	-issuer lazarevva-628-intr.crt \
	-cert lazarevva-628-ocsp-valid.crt
