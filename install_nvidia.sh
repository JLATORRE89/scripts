#!/bin/bash
# 11/13/2021
# Tested version: bash-4.2.46-34
# This scipt will install the NVIDIA Driver without installing the NVIDIA YUM repositories.
# A valid RHEL subscription or private YUM repository is needed for this script to function.
# You must be in multi-user target to execute the is script! (runlevel3)
echo $'\e[1;34m'Attempting to install NVIDIA Driver...$'\e[0m'
# change to runlevel 3 to stop current GUI
#systemctl isolate multi-user.target
# Set Driver Number Here
DRIVER=470.74
# !!!! DO NOT EDIT PAST THIS LINE !!!!
# Install dependencies.
yum install -y gcc make kernel-headers kernel-devel acpid libglvnd-glx libglvnd-opengl libglvnd-devel pkgconfig
# Create blacklist-nouveau.conf
echo $'\e[1;34m'Creating blacklist-nouveau.conf.$'\e[0m'
cat << 'EOF' > /etc/modprobe.d/blacklist-nouveau.conf

blacklist nouveau
options nouveau modeset=0

EOF

# Backup old grub configuration file
echo $'\e[1;34m'Creating backup grub configuration.$'\e[0m'
mv -f /etc/default/grub /etc/default/grub.bak

# Create new grub configuration file.
echo $'\e[1;34m'Generating new grun configuration file.$'\e[0m'
cat << 'EOF' > /etc/default/grub

GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rd.lvm.lv=rhel_rh98/root rd.lvm.lv=rhel_rh98/swap rhgb quiet rd.driver.blacklist=nouveau modprobe.blacklist=nouveau"
GRUB_DISABLE_RECOVERY="true"

EOF

# Rebuild BIOS GRUB2 Config
echo $'\e[1;34m'Building grub for BIOS.$'\e[0m'
grub2-mkconfig -o /boot/grub2/grub.cfg
# Rebuild UEFI GRUB2 Config
echo $'\e[1;34m'Building GRUB for UEFI.$'\e[0m'
grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg

# Create backup of initramfs.
echo $'\e[1;34m'Creating initramfs backup.$'\e[0m'
mv -f /boot/initramfs-$(uname -r).img /boot/initramfs-$(uname -r)-nouveau.img

# Build new initramfs
echo $'\e[1;34m'Building new initramfs.$'\e[0m'
dracut /boot/initramfs-$(uname -r).img $(uname -r)

# Note: This file may be corrupt from the vendor, check your hashes!
# This can be performed on a reference machine.
echo $'\e[1;34m'Compiling driver.$'\e[0m'
sh NVIDIA-Linux-x86_64-$DRIVER.run --add-this-kernel -z -s

# Copy file to something more usable for a repository.
echo $'\e[1;34m'Updating file names.$'\e[0m'
cp NVIDIA-Linux-x86_64-$DRIVER-custom.run NVIDIA-kernel-$(uname -r).run


# Execute Custom.runfile.
echo $'\e[1;34m'Installing driver.$'\e[0m'
# If driver already install, keep old one for previous kernels.
DriverCheck=$(lsmod | grep -c nvidia_modeset)
if [ $DriverCheck -eq 0 ]; then
	echo No drivered loaded.
	./NVIDIA-Linux-x86_64-$DRIVER-custom.run -z -s
else
	echo Found drivers loaded.
	./NVIDIA-Linux-x86_64-$DRIVER-custom.run -z -s -K
fi

# Build new initramfs
echo $'\e[1;34m'Building new initramfs.$'\e[0m'
dracut /boot/initramfs-$(uname -r).img $(uname -r) --force

echo Verify Install with lsmod | grep nvidia

# reboot system
echo $'\e[1;32m'Rebooting system.$'\e[0m'
echo Rebooting system.
reboot
