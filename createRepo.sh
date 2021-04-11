#!/bin/bash
# Install utilities for creating yum repositories.
echo "Installing dependencies..."
yum install -y yum-utils createrepo
echo "Starting Sync of: rhel-7-server-rpms"
reposync --gpgcheck -l --repoid=rhel-7-server-rpms --download_path=/var/www/html/repo --downloadcomps
echo "Starting Sync of: rhel-7-server-optional-rpms"
reposync --gpgcheck -l --repoid=rhel-7-server-optional-rpms --download_path=/var/www/html/repo --downloadcomps
echo "Starting Sync of: rhel-7-server-extras-rpms"
reposync --gpgcheck -l --repoid=rhel-7-server-extras-rpms --download_path=/var/www/html/repo --downloadcomps
echo "Starting Sync of: rhel-7-server-ansible-2.7-rpms"
reposync --gpgcheck -l --repoid=rhel-7-server-ansible-2.7-rpms --download_path=/var/www/html/repo --downloadcomps
echo "Creating Repo on local system: rhel-7-server-rpms"
createrepo -v /var/www/html/repo/rhel-7-server-rpms
echo "Creating Repo on local system: rhel-7-server-optional-rpms"
createrepo -v /var/www/html/repo/rhel-7-server-optional-rpms
echo "Creating Repo on local system: rhel-7-server-extras-rpms"
createrepo -v /var/www/html/repo/rhel-7-server-extras-rpms
echo "Creating Repo on local system: rhel-7-server-ansible-2.7-rpms"
createrepo -v /var/www/html/repo/rhel-7-server-ansible-2.7-rpms
echo "All work complete."
