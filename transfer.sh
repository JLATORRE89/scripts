#!/bin/bash
# 02/20/2020
# Script to transfer files from DMZ to Secure Zone.
# The default setting is all files associated with a <file>.hash value; this signifies a tar file is ready to be transferred.

cd /var/www/html/repo/
for f in *; do
    if [ -f "$f" ]; then
       if [[ "$f" == *".hash" ]]; then
          echo "Found: $f.hash"
          echo "Starting Transfer of tar files for $f."
          transfer="${f%.hash}".tar.gz
          # SCP used to allow for transfer to a Samba share or Windows IIS server.
          sshpass -f "/root/xfer" scp -r $transfer transfers@YU:/var/www/html/repo/$transfer
       fi
    fi
done
sshpass -f "/root/xfer" scp -r /var/www/html/repo/local.new transfers@YU:/var/www/html/repo/local.new
