#!/bin/bash
# This script requires an active RHEL Subscription and a device that connects to the internet.
# It will generate a directory in /var/www/html that contains all files needed to patch a system in an air-gapped
# development environment.
# The script will prompt the user for a URL to the errata data from redhat and a name for the patch folder.
# Tested on: Jan 12 2022
# Platform: RHEL 7.9
# BASH Version: 4.2.46-34
# This script comes with no warranty; use at own risk. Please contact owner if used in corporate environment.

# Colors - use with echo -e
reset='\033[0m'       # Text Reset
purple='\033[0;35m'       # Purple
uYellow='\033[4;33m'      # Yellow
green='\033[0;32m'        # Green
blue='\033[0;34m'         # Blue
cyan='\033[1;36m'        # Cyan

# comment these to disable interactive mode.
read -p "Enter URL:" url
read -p "Enter Patch name:" name

# uncomment these to disable interactive mode.
#url="https://access.redhat.com/errata/RHSA-2022:0063"
#name="kernel"

# configure YUM for downloading files.
cat <<EOF >>/etc/yum/pluginconf.d/downloadonly.conf
enabled=1
EOF

# create working directory
workdir="/var/www/html/$name"
mkdir -p "$workdir"
cd $workdir

# get rpm file list from internet
$(curl -o - $url | grep x86_64.rpm > rpm.txt)

# start yum transactions
echo -e ${green} Clean YUM repositories. ${reset}
rm -fr /var/cache/yum/*
yum clean all
echo -e ${uYellow} Rebuild YUM Cache. ${reset}
yum repolist
echo -e ${uYellow} Build YUM Package List.${reset}
echo Press Control+C to terminate if needed.
packageList=""
# trap ctrl+c to terminate
trap "exit" INT
while read -r line; do
        pName="$(basename $line .rpm)"
        echo -e ${cyan} $pName ${reset}
        packageList="$packageList $pName"
done < "rpm.txt"

# download packages
echo -e ${green} Downloading Package List. ${reset}
yum install --downloadonly --downloaddir=$workdir $packageList
rm $workdir/rpm.txt

# download createrepo
echo -e ${uYellow} Install createrepo if needed. ${reset}
yum install -y createrepo.noarch

# create the repository
echo -e ${green} Generating new repository for DISK use. ${reset}
createrepo .

# create sample repo file.
echo -e ${green} Create Sample Repo file. ${reset}
cat <<EOF >>$workdir/$name.repo
[$name repo]
name=Disk Repo for $name
mediaid=1359576196.686790
metadata_expire=-1
gpgcheck=1
cost=500
enabled=1
# Change to mounted directory to read from Disk.
baseurl=file:///mnt/disc/
EOF

#create update shell script.
echo -e ${green} Create update shell script. ${reset}
cat <<EOF >>$workdir/update.sh
#!/bin/bash
# Colors - use with echo -e
reset='\033[0m'       # Text Reset
uYellow='\033[4;33m'      # Yellow
echo -e ${uYellow} This will perform a local update. ${reset}
echo -e ${uYellow} This script does not use a repository and will skip broken packages. ${reset}
yum localupdate --disablerepo=* *.rpm --nogpgcheck --skip-broken -y
echo -e ${uYellow} All work complete. Changes can be reverted with yum transaction history or restore from backup. ${reset}
EOF

echo -e ${purple} All work complete, burn $workdir to a disk. ${reset}
