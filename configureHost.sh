#!/bin/bash
# Configure host for OCP cluster deployment

function CHECK_PACKAGES {
# Check and install required packages
subscription-manager register
subscription-manager repos --enable=rhel-7-server-rpms --enable=rhel-7-server-extras-rpms --enable=rhel-7-server-ose-4.7-rpms
yum groupinstall -y virtualization-client virtualization-platform virtualization-tools
yum install -y screen podman httpd-tools jq git
}

function CHECK_DIR {
# Check and create required directory
mkdir /ocp
chmod +x -R /ocp
}

function CONFIGURE_DNS {
	systemctl enable NetworkManager --now
	echo -e "[main]\ndns=dnsmasq" > /etc/NetworkManager/conf.d/nm-dns.conf
	echo "local=/${CLUSTER_NAME}.${DOMAIN}/" > ${DNS_DIR}/${CLUSTER_NAME}.conf
	echo "address=/apps.${CLUSTER_NAME}.${BASE_DOM}/192.168.122.1" >> ${DNS_DIR}/${CLUSTER_NAME}.conf
	echo "192.168.122.90 bootstrap.${CLUSTER_NAME}.${DOMAIN}" >> /etc/hosts
	echo "192.168.122.91 master0.${CLUSTER_NAME}.${DOMAIN}" >> /etc/hosts
	echo "192.168.122.92 master1.${CLUSTER_NAME}.${DOMAIN}" >> /etc/hosts
	echo "192.168.122.93 master2.${CLUSTER_NAME}.${DOMAIN}" >> /etc/hosts
	echo "192.168.122.94 worker0.${CLUSTER_NAME}.${DOMAIN}" >> /etc/hosts
	echo "192.168.122.95 worker1.${CLUSTER_NAME}.${DOMAIN}" >> /etc/hosts
	echo "192.168.122.1 lb.${CLUSTER_NAME}.${DOMAIN}" "api.${CLUSTER_NAME}.${DOMAIN}" "api-int.${CLUSTER_NAME}.${DOMAIN}" >> /etc/hosts
	systemctl reload NetworkManager
	systemctl restart libvirtd
}

function CONFIGURE_WEB {
	screen -S ws -dm bash -c "cd /ocp/*/; python -m SimpleHTTPServer 8080"
}

source $(pwd)/env
DNS_DIR=/etc/NetworkManager/dnsmasq.d

CHECK_PACKAGES
CHECK_DIR
CONFIGURE_DNS
CONFIGURE_WEB
