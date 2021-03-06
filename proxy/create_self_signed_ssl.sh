#!/bin/bash
set -e

command="openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout $CERTKEY -out $CERTCHAIN"

# Input values required by the command:
#        Country Name (2 letter code) [AU]:
#        State or Province Name (full name) [Some-State]:
#        Locality Name (eg, city) []:
#        Organization Name (eg, company) [Internet Widgits Pty Ltd]:
#        Organizational Unit Name (eg, section) []:
#        Common Name (e.g. server FQDN or YOUR name) []:
#        Email Address []:

country='XX'
state='Nowhere'
locality='Web'
organization='RAPyDo'
organization_unit='SSL'
common_name=$DOMAIN
# common_name='apiserver.dockerized.io'
email='user@nomail.org'

$command 2> /dev/null << EOF
$country
$state
$locality
$organization
$organization_unit
$common_name
$email
EOF

if [ "$?" == "0" ]; then
    echo "Created"
else
    echo "Failed..."
fi

# to read the cert file
# openssl x509 -in /etc/ssl/certs/nginx-selfsigned.crt -text
