### Deploy OpenShift 4.x on KVM in a disconnected fasion

#### What's in it for me
→ Useful for reproducing support case scenario

#### Architecture
┌───────────────────────────────────────────────────────────────────────────────────┐
│                                                                                   │
│   ┌───────────────────────────────────────────────────────────────────────────┐   │
│   │                                                                           │   │
│   │  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐  │   │
│   │  │         │ │         │ │         │ │         │ │         │ │         │  │   │
│   │  │         │ │         │ │         │ │         │ │         │ │         │  │   │
│   │  │         │ │         │ │         │ │         │ │         │ │         │  │   │
│   │  │         │ │         │ │         │ │         │ │         │ │         │  │   │
│   │  │         │ │         │ │         │ │         │ │         │ │         │  │   │
│   │  │         │ │         │ │         │ │         │ │         │ │         │  │   │
│   │  │         │ │         │ │         │ │         │ │         │ │         │  │   │
│   │  │         │ │         │ │         │ │         │ │         │ │         │  │   │
│   │  │         │ │         │ │         │ │         │ │         │ │         │  │   │
│   │  │ Bootstrap │  Master01 │  Master02 │  Master03 │  Worker01 │  Worker02  │   │
│   │  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘  │   │
│   │                                                                    RHEL KVM   │
│   └───────────────────────────────────────────────────────────────────────────┘   │
│                                                                                RHEV
└───────────────────────────────────────────────────────────────────────────────────┘

#### Pre-requisites
A virtual machine with pass-through host CPU. The host resources must meet:
  RAM:  80 GB
  CPU:  20
  DISK: 360 GB

#### Configure Pass-Through host CPU
See this [1] image.
[1]: https://drive.google.com/file/d/1f3kb7bhFbvUzFE0WMsI4B3wa6jNNQK6j/view?usp=sharing

#### Setup libvirt
yum groupinstall -y virtualization-client virtualization-platform virtualization-tools
yum install -y screen
mkdir /vms
chmod +xv -R /vms

#### Configure environement
CIDR=$(ip -4 a s $(virsh net-info default | awk '/Bridge:/{print $2}') | awk '/inet /{print $2}')
iptables -I INPUT 1 -p tcp -m tcp --dport 8080 -s $CIDR -j ACCEPT
screen -S ws -dm bash -c "cd /root/vms; python -m SimpleHTTPServer 8080"
mkdir /vms/bootstrap && cd /vms/bootstrap
wget -O rhcos.iso https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-4.7.13-x86_64-live.x86_64.iso
wget -O rootfs.img https://mirror.openshift.com/pub/openshift-v4/dependencies/rhcos/latest/latest/rhcos-4.7.13-x86_64-live-rootfs.x86_64.img
wget http://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/candidate-4.8/openshift-client-linux.tar.gz
wget http://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/candidate-4.8/openshift-install-linux.tar.gz
tar xfv openshift-client-linux.tar.gz oc
tar xfv openshift-install-linux.tar.gz openshift-install
if [ ! -f ~/.ssh/id_rsa.pub ]; then ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519; fi

#### Start VMs
VIRT_NET=default
WEB_IP=192.168.122.1
WEB_PORT=8080
MAC1=52:54:00:ed:9a:d1
MAC2=52:54:00:ed:9a:d2
IGNITION=bootstrap.ign
virsh destroy bootstrap
virsh undefine bootstrap
virt-install --name bootstrap \
  --disk rhcos.img --ram 16000 --vcpus 4 \
  --os-type linux --os-variant rhel7 \
  --network network=${VIRT_NET},mac=${MAC1} \
  --network network=${VIRT_NET},mac=${MAC2} \
  --location rhcos.iso --nographics \
  --extra-args "nomodeset rd.neednet=1 console=tty0 console=ttyS0 coreos.inst=yes coreos.inst.install_dev=vda coreos.live.rootfs_url=http://${HOST_IP}:${WEB_PORT}/rootfs.img coreos.inst.ignition_url=http://${WEB_IP}:${WEB_PORT}/${IGNITION}"
