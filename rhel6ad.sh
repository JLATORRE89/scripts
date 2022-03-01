#!/bin/bash
# RHEL6 reference: https://www.thegeekdiary.com/how-to-configure-ldap-client-on-centos-rhel-6-using-sssd/
SERVERIP = "xxx.xxx.xxx.xxx"
OU = "partition1"
DCBASE = "lan"
DCSUFFIX = "local"
# DO NOT EDIT BELOW THIS LINE
yum install sssd sssd-client
file = "/etc/nsswitch.conf"
search = "passwd: files"
replace = "passwd: files sss"
sed -i 's/$search/$replace/' $file
search = "shadow: files"
replace = "shadow: files sss"
sed -i 's/$search/$replace/' $file
search = "group: files"
replace = "group: files sss"
sed -i 's/$search/$replace/' $file
/etc/nsswitch.conf
authconfig --savebackup=/backups/authconfigbackup20220228
authconfig --enablesssd --enablesssdauth --ldapserver=$SERVERIP --ldapbasedn="lan.local" --enableldaptls --update
authconfig --enableldap --enableldapauth --ldapserver=ldap://ldap.$SERVERIP:389 --ldapbasedn="ou=$OU,dc=$DCBASE,dc=$DCSUFFIX" --enableldaptls --ldaploadcacert=https://ca.$SERVERIP/caCert.crt --update
