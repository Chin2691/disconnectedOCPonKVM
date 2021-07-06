#!/bin/bash
# Configure host for OCP cluster deployment

function CHECK_PACKAGES {
# Check and install required packages
subscription-manager register
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-ose-4.7-rpms
yum groupinstall -y virtualization-client virtualization-platform virtualization-tools
yum install -y screen podman httpd-tools jq
}

function CHECK_DIR {
# Check and create required directory
mkdir /vms
chmod +x -R /vms
}

CHECK_PACKAGES
CHECK_DIR
