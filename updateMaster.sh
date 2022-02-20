#!/bin/bash
# 02/20/2022
# This file drives the creation and maintenance of a local reposistory. It will create update.log and run in the backgro
und by default. This script requires local.temp be in /var/www/html/repo and that the IP of the yum servers be denoted w
ith YU in the http field. It will string replace the YU when found. You password file must be located at: /root/xfer.
# Dependencies: sshpass createrepo sub.sh transfer.sh createRepo.sh
exec >> update.log
echo "Work Started at: $(date +%m-%d-%Y-%T)"
source /var/www/tools/patchManager/sub.sh
source /var/www/tools/patchManager/createRepo.sh
# Prepare local repo file.
repo=$(</var/www/html/repo/local.temp)
newIp=$(ip a | grep 192 | awk -F ' ' '{print $2}' | awk '{ print substr( $0, 1, length($0)-3 ) }')
echo "$repo" | sed -r "s/[YU]+/$newIp/" > /var/www/html/repo/local.new

cd /var/www/html/repo
for f in *; do
    if [ -d "$f" ]; then
        echo "Creating Archive for: $f"
        tar -czvf $f.tar.gz $f
        echo "Creating hash for: $f"
        sha256sum $f.tar.gz >> $f.hash
    fi
done

# Begin transfer of files to destination.
source /var/www/tools/patchManager/transfer.sh
echo "All work complete at: $(date +%m-%d-%Y-%T)"
