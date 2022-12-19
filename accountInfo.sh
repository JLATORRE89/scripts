#!/bin/bash
#Depends:0 bash-4.2.46-34, sed-4.2.2-7, gawk-4.0.2-4

# Get user list from /etc/passwd
USERS=$(sed 's/:/ /' /etc/passwd | awk '{print $1 }')
# generate data for each user
for USER in $USERS
do
        echo Username: $USER
        chage -l $USER | grep expires
done
