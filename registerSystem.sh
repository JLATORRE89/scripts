#!/bin/bash
# Register new system to RHEL
echo "Attempting to register system, enter your RHEL credentials when prompted."
subscription-manager register
# Assgin System to Pool using auto-attach. Use --pool= option if this fails.
#  subscription-manager attach --pool=<POOL_ID>
echo "Attaching to Subscription Pool."
subscription-manager attach --auto
# Enable respective repositories
echo "Enabling repositories."
subscription-manager repos --enable=rhel-7-server-rpms
subscription-manager repos --enable=rhel-7-server-optional-rpms
subscription-manager repos --enable=rhel-7-server-extras-rpms
subscription-manager repos --enable=rhel-7-server-ansible-2.7-rpms
echo "All work complete."
