#!/bin/bash

set -ve

EMAIL="vsftp@example.com"

cd "$(dirname "$0")"

echo "make CA"
PRIVKEY="test"
openssl req -new -x509 -days 3650 -keyout ca.key -out ca.pem -subj "/C=DE/ST=NRW/L=Earth/O=Example Company/OU=IT/CN=www.example.com/emailAddress=admin@example.com" -passout pass:$PRIVKEY

echo "make server cert"
openssl req -new -nodes -x509 -out server.pem -keyout server.key -days 3650 -subj "/C=DE/ST=NRW/L=Earth/O=Example Company/OU=IT/CN=www.example.com/emailAddress=${EMAIL}"

echo "make client cert"
#openssl req -new -nodes -x509 -out client.pem -keyout client.key -days 3650 -subj "/C=DE/ST=NRW/L=Earth/O=Example Company/OU=IT/CN=www.example.com/emailAddress=${EMAIL}"

openssl genrsa -out client.key 2048
echo "00" > ca.srl
openssl req -sha256 -key client.key -new -out client.req -subj "/C=DE/ST=NRW/L=Earth/O=Example Company/OU=IT/CN=client.example.com/emailAddress=${EMAIL}"
# Adding -addtrust clientAuth makes certificates Go can't read
openssl x509 -req -days 3650 -in client.req -CA ca.pem -CAkey ca.key -passin pass:$PRIVKEY -out client.pem # -addtrust clientAuth

openssl x509 -extfile openssl.conf -extensions ssl_client -req -days 3650 -in client.req -CA ca.pem -CAkey ca.key -passin pass:$PRIVKEY -out client.pem
