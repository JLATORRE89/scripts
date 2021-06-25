#!/bin/bash
#Depends:0 bash-4.2.46-34, sed-4.2.2-7, gawk-4.0.2-4
sed 's/:/ /' /etc/passwd | awk '{print }'
chage -l root | grep expires
