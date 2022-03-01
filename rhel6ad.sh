#!/bin/bash
# RHEL6 reference: https://www.thegeekdiary.com/how-to-configure-ldap-client-on-centos-rhel-6-using-sssd/
SERVERIP = "192.168.86.24"
OU = "partition1"
DCBASE = "lan"
DCSUFFIX = "local"
# DO NOT EDIT BELOW THIS LINE
echo "Install SSSD..."
yum install sssd sssd-client
echo "Update nsswitch.conf"
file="/etc/nsswitch.conf"
search="passwd: files"
replace="passwd: files sss"
sed -i 's/$search/$replace/' $file
search="shadow: files"
replace="shadow: files sss"
sed -i 's/$search/$replace/' $file
search="group: files"
replace="group: files sss"
sed -i 's/$search/$replace/' $file
echo "Backup Defult authconfig file"
authconfig --savebackup=/backups/authconfigbackup20220228
echo "Make it happen"
authconfig --enablesssd --enablesssdauth --ldapserver=$SERVERIP --ldapbasedn="$DCBASE.$DCSUFFIX" --enableldaptls --update
# NOTE: caCert.crt will not exist unless AD FS is installed, it will not work on AD LDS
# REFERENCE: https://docs.microsoft.com/en-us/troubleshoot/windows-server/identity/enable-ldap-over-ssl-3rd-certification-authority
authconfig --enableldap --enableldapauth --ldapserver=ldap://ldap.$SERVERIP:389 --ldapbasedn="ou=$OU,dc=$DCBASE,dc=$DCSUFFIX" --enableldaptls --ldaploadcacert=https://ca.$SERVERIP/caCert.crt --update
echo "All work complete."
