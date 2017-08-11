#!/bin/bash

# FIXME: rename me in extra_b2access.sh

# NOTE: now based on Globus toolkit 6

################################
# GSI & certificates
add-irods-X509 rodsminer admin
add-irods-X509 guest

echo
echo "Completed GSI setup"
echo

################################
## Add and validate the B2ACCESS certification authority
cd $CADIR
gridcerts="$GRIDCERTDIR/certificates"

## DEV
label="b2access.ca.dev"
caid=$(openssl x509 -in $B2ACCESS_CAS/$label.pem -hash -noout)
# caid=$(openssl x509 -in $label.pem -hash -noout)
if [ `ls -1 $gridcerts/$caid.* 2> /dev/null | wc -l` != "2" ]; then
    echo "B2ACCESS CA [dev]: label is $caid"
    cp $B2ACCESS_CAS/$label.* $CADIR/
    mv $label.pem ${caid}.0
    mv $label.signing_policy ${caid}.signing_policy
    cp $CADIR/$caid* $gridcerts/
fi


## PROD
label="b2access.ca.prod"
caid=$(openssl x509 -in $B2ACCESS_CAS/$label.pem -hash -noout)
if [ `ls -1 $gridcerts/$caid.* 2> /dev/null | wc -l` != "2" ]; then
    echo "B2ACCESS CA [prod]: label is $caid"
    cp $B2ACCESS_CAS/$label.* $CADIR/
    mv $label.pem ${caid}.0
    mv $label.signing_policy ${caid}.signing_policy
    cp $CADIR/$caid* $gridcerts/
fi

chown -R $IRODS_USER /opt/certificates

################################
# Add bash rc commands
echo -e "echo\\necho 'Become irods administrator user with the command:'\\necho '$ berods'" >> /root/.bashrc
echo -e "echo\\necho 'Switch irods GSI user then with the command:'\\necho '$ switch-gsi USERNAME'\\necho" >> /root/.bashrc

# ################################
# # Cleanup
### WARNING: starting from irods 4.2.1 this breaks things
### there is a file /tmp/irodsServer.1247 which seems to be the irods pid...
# echo "Cleaning temporary files"
# rm -rf /tmp/*
