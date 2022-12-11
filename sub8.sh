#!/bin/bash
# Register new system to RHEL
echo "Attempting to register system, enter your RHEL credentials when prompted."
subscription-manager register
# Assgin System to Pool
echo "Attaching to Subscription Pool."
subscription-manager attach --pool=REPLACEME
# Enable respective repositories
echo "Enabling repositories."
subscription-manager repos --enable=rhel-8-for-x86_64-baseos-rpms
subscription-manager repos --enable=rhel-8-for-x86_64-appstream-rpms
subscription-manager repos --enable=codeready-builder-for-rhel-8-x86_64-rpms
echo "All work complete."
