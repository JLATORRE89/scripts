#!/bin/bash
# This script requires the following:
# 1. That the user be on the system you are SSHing to.
# 2. That there is an SSH key installed and usable on the remote system
# 3. That the user attempting to access YUM is defined in the SUDOERs file.
# Example Definition: builder ALL=(ALL) NOPASSWD: /bin/rpm, /usr/bin/up2date, /usr/bin/yum
# If more rights are requested, enable the sys group and add the respective user to the group.
#whoami
user=builder
ssh $user@localhost 'yum clean all'
ssh $user@localhost 'bash -s' < job.sh
#sudo yum clean all
#sudo yum update -y
