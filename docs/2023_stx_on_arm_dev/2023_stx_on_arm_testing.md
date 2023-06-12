# StarlingX Testing on ARM64 Ampere Server

[TOC]

## Test Info

### Test Matrix

| Test case    | Hosts      | Deployment | With Ceph | With Rook-Ceph | With OpenStack | Result | Comments        |
| ------------ | ---------- | ---------- | --------- | -------------- | -------------- | ------ | --------------- |
| Installation | HPE-Ampere | AIO-SX     | no        | no             | no             | Pass   |                 |
| Bootstrap    | HPE-Ampere | AIO-SX     | no        | no             | no             | Pass   |                 |
| Unlock       | HPE-Ampere | AIO-SX     | no        | no             | no             | Pass   |                 |
| SR-IOV       | HPE-Ampere | AIO-SX     | no        | no             | no             | Pass   |                 |
| Installation | VMs        | AIO-DX     | Yes       | no             | no             | Pass   |                 |
| Bootstrap    | VMs        | AIO-DX     | Yes       | no             | no             | Pass   |                 |
| Unlock       | VMs        | AIO-DX     | Yes       | no             | no             | Pass   |                 |
| Installation | VMs        | STD(2+2)   | Yes       | no             | no             | Pass   |                 |
| Bootstrap    | VMs        | STD(2+2)   | Yes       | no             | no             | Pass   |                 |
| Unlock       | VMs        | STD(2+2)   | Yes       | no             | no             | Pass   |                 |
| Installation | VMs        | STD(2+2+2) | Yes       | no             | no             | Pass   |                 |
| Bootstrap    | VMs        | STD(2+2+2) | Yes       | no             | no             | Pass   |                 |
| Unlock       | VMs        | STD(2+2+2) | Yes       | no             | no             | Pass   |                 |

### Server Info: HPE RL300 Gen11

* Product Name: ProLiant RL300 Gen11
* CPU: 
  * Ampere(R) Altra(R) Processor
  * 3000 MHz
  * 80/80 cores; 80 threads
* Memory: 16G 3200MHz X 16 = 256G
* Network:
  * Adapter 1: Mellanox MT2894 Family [ConnectX-6 Lx] Adapter
  * http://hcl.xenserver.org/networkadapters/471/Mellanox_Technologies_MT2894_Family__ConnectX_6_Lx___Adapter
  * PCI ID: 15b3:101f
  * SRIOV: 
    * Min Firmware: 26.30.1004 LNV0000000037
    * Min Driver: 5.6-2.0.9
    * Max VFs/PF: 8
* Disks:
  * nvme0n1: VO001920KYDMT 1T

## 1. Bera Metal AIO-SX Installation and deployment steps

### 1.0 Bundle the docker images into ISO

* Original ISO:
  * $STX_BUILD_HOME/localdisk/deploy/starlingx-qemuarm64-cd.iso

* offline dokcer image tar: /path/to/docker_img/docker_img_arm64.tar.gz

* Scripts:
  * https://github.com/jackiehjm/stx-builds/blob/master/build_stx_debian/iso-tools/stx-iso-utils.sh
  * https://github.com/jackiehjm/stx-builds/blob/master/build_stx_debian/iso-tools/update-iso.sh

* modifiy the scripts as following:

```
$ diff update-iso.sh_orig update-iso.sh
377,379c377,380
<     ilog "adding ${ADDON} to ${BUILDDIR}/ks-addon.cfg"
<     rm -f "${BUILDDIR}"/ks-addon.cfg
<     cp "${ADDON}" "${BUILDDIR}"/ks-addon.cfg
---
>     ilog "adding ${ADDON} to ${BUILDDIR}/kickstart/kickstart.cfg"
>     mv "${BUILDDIR}"/kickstart/kickstart.cfg "${BUILDDIR}"/kickstart/kickstart.cfg_orig
>     cp "${ADDON}" "${BUILDDIR}"/kickstart/kickstart.cfg
>     cp /path/to/docker_img/docker_img_arm64.tar.gz "${BUILDDIR}"/
```

* get the modified kickstart file
  * https://github.com/jackiehjm/stx-builds/blob/master/build_stx_debian/iso-tools/kickstart.cfg

* run the script

```
ISO_INPUT=starlingx-qemuarm64-cd
ISO_OUTPUT=starlingx-arm64-cd

mkdir scripts input output
cp update-iso.sh stx-iso-utils.sh scripts
cp kickstart.cfg input

# change instdev to nvme
$ sudo ./scripts/update-iso.sh -i ${ISO_INPUT}.iso -o ./output/${ISO_OUTPUT}-nvme.iso -p instdev=/dev/nvme0n1

# Bundle the docker images:
$ sudo ./scripts/update-iso.sh -i ${ISO_INPUT}.iso -o ./output/${ISO_OUTPUT}-bundle.iso -a input/kickstart.cfg

# Bundle the docker images and change instdev to nvme
$ sudo ./scripts/update-iso.sh -i ${ISO_INPUT}.iso -o ./output/${ISO_OUTPUT}-bundle-nvme.iso -a input/kickstart.cfg -p instdev=/dev/nvme0n1
```

### 1.1 Installation

* Mount the ISO image as Virtual CD, and restart the server.

* Make the following menu selections in the installer:
  * First menu: Select ‘All-in-one Controller Configuration’
  * Second menu: Select ‘Graphical Console’ or ‘Serial Console’ depending on your terminal access to the console port.

* Wait for non-interactive installation to complete and server to reboot.

### 1.2 Bootstrap

* Login using the username/password of “sysadmin” / “sysadmin” and change the password to “Li69nux*”

```
export OAM_DEV=enP2p1s0f0
export OAM_VLAN=enP2p1s0f0.5
export OAM_NETWORK=147.11.89
export OAM_IP=201
export OAM_SUB=147.11.89.0/22

export CONTROLLER0_OAM_CIDR=${OAM_NETWORK}.${OAM_IP}/22
export DEFAULT_OAM_GATEWAY=147.11.88.1

sudo ip link add link $OAM_DEV name $OAM_VLAN type vlan id 5
sudo ip address add $CONTROLLER0_OAM_CIDR dev $OAM_VLAN
sudo ip link set up dev $OAM_DEV
sudo ip link set up dev $OAM_VLAN
sudo ip route add default via $DEFAULT_OAM_GATEWAY dev $OAM_VLAN

echo "nameserver 147.11.57.128" | sudo tee -a /etc/resolv.conf

cat <<EOF > localhost.yml
system_mode: simplex
external_oam_subnet: ${OAM_SUB}
external_oam_gateway_address: ${DEFAULT_OAM_GATEWAY}
external_oam_floating_address: ${OAM_NETWORK}.${OAM_IP}

dns_servers:
  - 147.11.57.128

admin_password: Li69nux*
ansible_become_pass: Li69nux*

offline_img_dir: /opt/platform-backup/docker_img_arm64

EOF


ansible-playbook -vvv /usr/share/ansible/stx-ansible/playbooks/bootstrap.yml
```


### 1.3 Configure after bootstrap

```
source /etc/platform/openrc

OAM_IF=enP2p1s0f0
system host-if-modify controller-0 $OAM_IF -c platform -n oam0
system host-if-add -V 5 controller-0 oam0.5 vlan oam0
system interface-network-assign controller-0 oam0.5 oam

# unlock controller-0
system host-unlock controller-0
```

### 1.4 Runtime testing

* system check:

```
[sysadmin@controller-0 ~(keystone_admin)]$ system host-list
+----+--------------+-------------+----------------+-------------+--------------+
| id | hostname     | personality | administrative | operational | availability |
+----+--------------+-------------+----------------+-------------+--------------+
| 1  | controller-0 | controller  | unlocked       | enabled     | available    |
+----+--------------+-------------+----------------+-------------+--------------+

[sysadmin@controller-0 ~(keystone_admin)]$ lspci |grep -i mell
0002:01:00.0 Ethernet controller: Mellanox Technologies MT2894 Family [ConnectX-6 Lx]
0002:01:00.1 Ethernet controller: Mellanox Technologies MT2894 Family [ConnectX-6 Lx]

[sysadmin@controller-0 ~(keystone_admin)]$ lsmod|grep mlx
mlx5_ib               401408  0
mlx5_core            1617920  1 mlx5_ib
mlxfw                  32768  1 mlx5_core
mlxdevm               172032  1 mlx5_core
psample                20480  1 mlx5_core
tls                   110592  1 mlx5_core
ib_uverbs             155648  2 rdma_ucm,mlx5_ib
ib_core               409600  6 rdma_cm,iw_cm,rdma_ucm,ib_uverbs,mlx5_ib,ib_cm
mlx_compat             20480  19 rdma_cm,rdma_rxe,mlxdevm,rpcrdma,ib_srp,nvme_rdma,nvmet_rdma,xprtrdma,iw_cm,svcrdma,ib_iser,ib_isert,ib_core,rdma_ucm,ib_uverbs,mlx5_ib,ib_cm,mlx5_core,ib_ucm

[sysadmin@controller-0 ~(keystone_admin)]$ modinfo mlx5_core|grep version:
version:        5.8-1.0.1
srcversion:     C3E7649BC96C0107F0AD6A6

[sysadmin@controller-0 ~(keystone_admin)]$ system host-ethernet-port-show controller-0 cb30eef8-6ab7-407b-b026-c7c1d02142b2
+----------------+--------------------------------------+
| Property       | Value                                |
+----------------+--------------------------------------+
| name           | enP2p1s0f0                           |
| namedisplay    | None                                 |
| mac            | b8:3f:d2:4f:8a:88                    |
| pciaddr        | 0002:01:00.0                         |
| processor      | 0                                    |
| autoneg        | Yes                                  |
| bootp          | False                                |
| pclass         | Ethernet controller [0200]           |
| pvendor        | Mellanox Technologies [15b3]         |
| pdevice        | MT2894 Family [ConnectX-6 Lx] [101f] |
| link_mode      | 0                                    |
| capabilities   | {}                                   |
| uuid           | cb30eef8-6ab7-407b-b026-c7c1d02142b2 |
| host_uuid      | 83315f6e-634d-4baa-80d5-8159ea29afc2 |
| interface_uuid | 5f4e018b-fc57-47ad-9028-4dabcecef1d6 |
| created_at     | 2023-03-31T04:16:33.696701+00:00     |
| updated_at     | 2023-03-31T06:10:20.101918+00:00     |
+----------------+--------------------------------------+

[sysadmin@controller-0 ~(keystone_admin)]$ dpdk-devbind.py --status-dev net

Network devices using kernel driver
===================================
0002:01:00.0 'MT2894 Family [ConnectX-6 Lx] 101f' if=enP2p1s0f0 drv=mlx5_core unused=
0002:01:00.1 'MT2894 Family [ConnectX-6 Lx] 101f' if=enP2p1s0f1 drv=mlx5_core unused=

[sysadmin@controller-0 ~(keystone_admin)]$ cat /sys/bus/pci/devices/0002\:01\:00.1/sriov_totalvfs
8
[sysadmin@controller-0 ~(keystone_admin)]$ cat /sys/bus/pci/devices/0002\:01\:00.1/sriov_numvfs
0
```

* SR-IOV test:
  * ref: https://docs.starlingx.io/node_management/kubernetes/node_interfaces/provisioning-sr-iov-interfaces-using-the-cli.html
  * https://docs.nvidia.com/networking/pages/viewpage.action?pageId=12013542#SingleRootIOVirtualization(SRIOV)-cx4/cx5sr-iovconfigConfiguringSR-IOVforConnectX-4/ConnectX-5/ConnectX-6(Ethernet)

```
system host-lock controller-0

# add data netwokr
#system datanetwork-add datanet-a flat
system datanetwork-add datanet-a vlan

# enable sriov
system host-label-assign controller-0 sriovdp=enabled

system host-if-modify -m 1500 -n sriov1 -c pci-sriov -N 8 --vf-driver=netdevice controller-0 enP2p1s0f1
system interface-datanetwork-assign controller-0 sriov1 datanet-a

system host-unlock controller-0
```

output:

```
[sysadmin@controller-0 ~(keystone_admin)]$ system host-if-modify -m 1500 -n sriov1 -c pci-sriov -N 8 --vf-driver=netdevice controller-0 enP2p1s0f1
+------------------+--------------------------------------+
| Property         | Value                                |
+------------------+--------------------------------------+
| ifname           | sriov1                               |
| iftype           | ethernet                             |
| ports            | ['enP2p1s0f1']                       |
| imac             | b8:3f:d2:4f:8a:89                    |
| imtu             | 1500                                 |
| ifclass          | pci-sriov                            |
| ptp_role         | none                                 |
| aemode           | None                                 |
| schedpolicy      | None                                 |
| txhashpolicy     | None                                 |
| primary_reselect | None                                 |
| uuid             | dc22824a-6158-4150-84ed-34243f664f11 |
| ihost_uuid       | 83315f6e-634d-4baa-80d5-8159ea29afc2 |
| vlan_id          | None                                 |
| uses             | []                                   |
| used_by          | []                                   |
| created_at       | 2023-03-31T04:16:33.763352+00:00     |
| updated_at       | 2023-03-31T09:05:14.494370+00:00     |
| sriov_numvfs     | 8                                    |
| sriov_vf_driver  | netdevice                            |
| max_tx_rate      | None                                 |
| accelerated      | [False]                              |
+------------------+--------------------------------------+

[sysadmin@controller-0 ~(keystone_admin)]$ system host-if-list -a controller-0
+--------------------------------------+--------+-----------+----------+---------+----------------+----------+-------------+------------+
| uuid                                 | name   | class     | type     | vlan id | ports          | uses i/f | used by i/f | attributes |
+--------------------------------------+--------+-----------+----------+---------+----------------+----------+-------------+------------+
| 5c69eb86-11d8-4c68-8532-9420e668e3e4 | oam0.5 | platform  | vlan     | 5       | []             | ['oam0'] | []          | MTU=1500   |
| 5f4e018b-fc57-47ad-9028-4dabcecef1d6 | oam0   | platform  | ethernet | None    | ['enP2p1s0f0'] | []       | ['oam0.5']  | MTU=1500   |
| dc22824a-6158-4150-84ed-34243f664f11 | sriov1 | pci-sriov | ethernet | None    | ['enP2p1s0f1'] | []       | []          | MTU=1500   |
| f0a5bbdf-839c-41c2-8965-6c5bb9f27851 | lo     | platform  | virtual  | None    | []             | []       | []          | MTU=1500   |
+--------------------------------------+--------+-----------+----------+---------+----------------+----------+-------------+------------+

[sysadmin@controller-0 ~(keystone_admin)]$ sudo cat /sys/class/infiniband/mlx5_1/device/mlx5_num_vfs
8
[sysadmin@controller-0 ~(keystone_admin)]$ cat /sys/bus/pci/devices/0002\:01\:00.1/sriov_numvfs
8

[sysadmin@controller-0 ~(keystone_admin)]$ lspci |grep Mellanox
0002:01:00.0 Ethernet controller: Mellanox Technologies MT2894 Family [ConnectX-6 Lx]
0002:01:00.1 Ethernet controller: Mellanox Technologies MT2894 Family [ConnectX-6 Lx]
0002:01:01.2 Ethernet controller: Mellanox Technologies ConnectX Family mlx5Gen Virtual Function
0002:01:01.3 Ethernet controller: Mellanox Technologies ConnectX Family mlx5Gen Virtual Function
0002:01:01.4 Ethernet controller: Mellanox Technologies ConnectX Family mlx5Gen Virtual Function
0002:01:01.5 Ethernet controller: Mellanox Technologies ConnectX Family mlx5Gen Virtual Function
0002:01:01.6 Ethernet controller: Mellanox Technologies ConnectX Family mlx5Gen Virtual Function
0002:01:01.7 Ethernet controller: Mellanox Technologies ConnectX Family mlx5Gen Virtual Function
0002:01:02.0 Ethernet controller: Mellanox Technologies ConnectX Family mlx5Gen Virtual Function
0002:01:02.1 Ethernet controller: Mellanox Technologies ConnectX Family mlx5Gen Virtual Function
```

After unlock:
```
cat <<EOF > net1.yaml
apiVersion: "k8s.cni.cncf.io/v1"
kind: NetworkAttachmentDefinition
metadata:
  name: net1
  annotations:
    k8s.v1.cni.cncf.io/resourceName: intel.com/pci_sriov_net_datanet_a
spec:
  config: '{
      "cniVersion": "0.3.0",
      "type": "sriov"
    }'
EOF

kubectl create -f net1.yaml

cat << EOF >> pod1.yaml

apiVersion: v1
kind: Pod
metadata:
  name: pod1
  annotations:
    k8s.v1.cni.cncf.io/networks: '[
        { "name": "net1", "interface": "sriov0" }
    ]'
spec:
  containers:
  - name: pod1
    image: centos:7
    imagePullPolicy: IfNotPresent
    command: [ "/bin/bash", "-c", "--" ]
    args: [ "while true; do sleep 300000; done;" ]
    resources:
      requests:
        intel.com/pci_sriov_net_datanet_a: '1'
      limits:
        intel.com/pci_sriov_net_datanet_a: '1'

EOF

kubectl create -f pod1.yaml

kubectl exec -n default -it pod1 -- bash
yum update

[sysadmin@controller-0 ~(keystone_admin)]$ kubectl exec -n default -it pod1 -- ip link show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: tunl0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN mode DEFAULT group default qlen 1000
    link/ipip 0.0.0.0 brd 0.0.0.0
4: eth0@if28: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 16:05:b6:03:23:97 brd ff:ff:ff:ff:ff:ff link-netnsid 0
26: sriov0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc mq state DOWN mode DEFAULT group default qlen 1000
    link/ether d6:73:7d:17:e7:c5 brd ff:ff:ff:ff:ff:ff

```

## 2. VM Installation and deployment steps

### 2.1 Host setup

```
apt-get update

# Clone the StarlingX tools repo:
apt-get install -y git
cd $HOME
git clone https://opendev.org/starlingx/tools.git

# Apply fix for ARM
FIX_BRANCH="arm64/20230515-stx80-native"

cd $STX_REPO_ROOT/stx-tools
git fetch https://github.com/jackiehjm/stx-tools $FIX_BRANCH
git checkout -b $FIX_BRANCH FETCH_HEAD

# Install required packages:
cd $HOME/tools/deployment/libvirt/
bash install_packages.sh
```

### 2.2 AIO-DX

#### 2.2.1 Prepare VM env and install from ISO image

```
# setup the networks for vm:
bash setup_network.sh

# Get the ISO and setup vm:
bash setup_configuration.sh -c duplex -i ./starlingx-qemuarm64-20230526165532-cd.iso

# Install in vm:
sudo vish console duplex-controller-0

# Make the following menu selections in the installer:
# First menu: Select ‘All-in-one Controller Configuration’
# Second menu: Select ‘Graphic Console’
```

#### 2.2.2 Bootstrap

* Login after reboot and change the password

```
export OAM_DEV=enp2s1
export OAM_NETWORK=10.10.10
export OAM_IP=3
export OAM_IP0=4
export OAM_IP1=5

export CONTROLLER0_OAM_CIDR=${OAM_NETWORK}.${OAM_IP}/24
export DEFAULT_OAM_GATEWAY=10.10.10.1
sudo ip address add $CONTROLLER0_OAM_CIDR dev $OAM_DEV
sudo ip link set up dev $OAM_DEV
sudo ip route add default via $DEFAULT_OAM_GATEWAY dev $OAM_DEV

cat <<EOF > localhost.yml
system_mode: duplex

external_oam_subnet: ${OAM_NETWORK}.0/24
external_oam_gateway_address: ${DEFAULT_OAM_GATEWAY}
external_oam_floating_address: ${OAM_NETWORK}.${OAM_IP}
external_oam_node_0_address: ${OAM_NETWORK}.${OAM_IP0}
external_oam_node_1_address: ${OAM_NETWORK}.${OAM_IP1}

dns_servers:
  - 147.11.57.128
  - 8.8.8.8

offline_img_dir: /home/sysadmin/docker_img_arm64

admin_password: Li69nux*
ansible_become_pass: Li69nux*
EOF

# use scp/wget to get docker_img_arm64_20230515.tar.gz
tar xvf docker_img_arm64_20230515.tar.gz

ansible-playbook -vvv /usr/share/ansible/stx-ansible/playbooks/bootstrap.yml
```

#### 2.2.3 Configure after bootstrap

```
source /etc/platform/openrc

OAM_IF=enp2s1
MGMT_IF=enp2s2
system host-if-modify controller-0 lo -c none
IFNET_UUIDS=$(system interface-network-list controller-0 | awk '{if ($6=="lo") print $4;}')
for UUID in $IFNET_UUIDS; do
    system interface-network-remove ${UUID}
done
system host-if-modify controller-0 $OAM_IF -c platform
system interface-network-assign controller-0 $OAM_IF oam
system host-if-modify controller-0 $MGMT_IF -c platform
system interface-network-assign controller-0 $MGMT_IF mgmt
system interface-network-assign controller-0 $MGMT_IF cluster-host

# For ceph
system storage-backend-add ceph --confirmed

system host-disk-list controller-0
system host-disk-list controller-0 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-0 {}
system host-stor-list controller-0

# unlock controller-0
system host-unlock controller-0
```

#### 2.2.4 Install controller-1 and config

* start vm for controller-1
```
sudo virsh start dedicatedstorage-controller-1
```

* on controller-0
```
# install controller-1
system host-update 2 personality=controller

# configure controller-1
OAM_IF=enp2s1
system host-if-modify controller-1 $OAM_IF -c platform
system interface-network-assign controller-1 $OAM_IF oam
system interface-network-assign controller-1 mgmt0 cluster-host

# For ceph
system host-disk-list controller-1
system host-disk-list controller-1 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-1 {}
system host-stor-list controller-1

# unlock controller-1
system host-unlock controller-1
```

#### 2.2.5 Runtime testing

* system check:
```
[sysadmin@controller-0 pxeboot(keystone_admin)]$ system host-list
+----+--------------+-------------+----------------+-------------+--------------+
| id | hostname     | personality | administrative | operational | availability |
+----+--------------+-------------+----------------+-------------+--------------+
| 1  | controller-0 | controller  | unlocked       | enabled     | available    |
| 2  | controller-1 | controller  | unlocked       | enabled     | available    |
+----+--------------+-------------+----------------+-------------+--------------+

[sysadmin@controller-0 pxeboot(keystone_admin)]$ ceph -s
  cluster:
    id:     c8dabfa7-5bc1-4306-9fac-3c8f469de37a
    health: HEALTH_OK

  services:
    mon: 1 daemons, quorum controller (age 3d)
    mgr: controller-0(active, since 3d), standbys: controller-1
    mds:  2 up:standby
    osd: 2 osds: 2 up (since 6h), 2 in (since 6h)

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   3.0 GiB used, 395 GiB / 398 GiB avail
    pgs:

```

### 2.3 controllerstorage: STD (2+2)

#### 2.3.1 Prepare VM env and install from ISO image

```
# setup the networks for vm:
bash setup_network.sh

# Get the ISO and setup vm:
bash setup_configuration.sh -c controllerstorage -i ./starlingx-qemuarm64-20230526165532-cd.iso

# Install in vm:
sudo vish console controllerstorage-controller-0

# Make the following menu selections in the installer:
# First menu: Select ‘All-in-one Controller Configuration’
# Second menu: Select ‘Graphic Console’
```

#### 2.3.2 Bootstrap

* Login after reboot and change the password

```
export OAM_DEV=enp2s1
export OAM_NETWORK=10.10.10
export OAM_IP=3
export OAM_IP0=4
export OAM_IP1=5

export CONTROLLER0_OAM_CIDR=${OAM_NETWORK}.${OAM_IP}/24
export DEFAULT_OAM_GATEWAY=10.10.10.1
sudo ip address add $CONTROLLER0_OAM_CIDR dev $OAM_DEV
sudo ip link set up dev $OAM_DEV
sudo ip route add default via $DEFAULT_OAM_GATEWAY dev $OAM_DEV

cat <<EOF > localhost.yml
system_mode: duplex

external_oam_subnet: ${OAM_NETWORK}.0/24
external_oam_gateway_address: ${DEFAULT_OAM_GATEWAY}
external_oam_floating_address: ${OAM_NETWORK}.${OAM_IP}
external_oam_node_0_address: ${OAM_NETWORK}.${OAM_IP0}
external_oam_node_1_address: ${OAM_NETWORK}.${OAM_IP1}

dns_servers:
  - 147.11.57.128
  - 8.8.8.8

offline_img_dir: /home/sysadmin/docker_img_arm64

admin_password: Li69nux*
ansible_become_pass: Li69nux*
EOF

# use scp/wget to get docker_img_arm64_20230515.tar.gz
tar xvf docker_img_arm64_20230515.tar.gz

ansible-playbook -vvv /usr/share/ansible/stx-ansible/playbooks/bootstrap.yml
```

#### 2.3.3 Configure after bootstrap

```
source /etc/platform/openrc

OAM_IF=enp2s1
MGMT_IF=enp5s0
system host-if-modify controller-0 lo -c none
IFNET_UUIDS=$(system interface-network-list controller-0 | awk '{if ($6=="lo") print $4;}')
for UUID in $IFNET_UUIDS; do
    system interface-network-remove ${UUID}
done
system host-if-modify controller-0 $OAM_IF -c platform
system interface-network-assign controller-0 $OAM_IF oam
system host-if-modify controller-0 $MGMT_IF -c platform
system interface-network-assign controller-0 $MGMT_IF mgmt
system interface-network-assign controller-0 $MGMT_IF cluster-host

# For ceph
system storage-backend-add ceph --confirmed


# unlock controller-0
system host-unlock controller-0
```

#### 2.3.4 Install controller-1 and config

* start vm for controller-1
```
sudo virsh start controllerstorage-controller-1
```

```
# install controller-1
system host-update 2 personality=controller
```

```
# configure controller-1
OAM_IF=enp2s1
system host-if-modify controller-1 $OAM_IF -c platform
system interface-network-assign controller-1 $OAM_IF oam
system interface-network-assign controller-1 mgmt0 cluster-host

# For ceph
system host-disk-list controller-1
system host-disk-list controller-1 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-1 {}
system host-stor-list controller-1

# unlock controller-1
system host-unlock controller-1
```

#### 2.3.5 install worker and config

```
system host-update 3 personality=worker hostname=worker-0
system host-update 4 personality=worker hostname=worker-1

system ceph-mon-add worker-0

system host-disk-list controller-0
system host-disk-list controller-0 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-0 {}
system host-stor-list controller-0
system host-disk-list controller-1
system host-disk-list controller-1 | awk '/\/dev\/sdb/{print $2}' | xargs -i system host-stor-add controller-1 {}
system host-stor-list controller-1

for NODE in worker-0 worker-1; do
   system interface-network-assign $NODE mgmt0 cluster-host
done

for NODE in worker-0 worker-1; do
   system host-unlock $NODE
done
```

#### 2.3.6 Runtime testing

* system check:
```
[sysadmin@controller-0 pxelinux.cfg(keystone_admin)]$ system ceph-mon-list
+--------------------------------------+-------+--------------+------------+------+
| uuid                                 | ceph_ | hostname     | state      | task |
|                                      | mon_g |              |            |      |
|                                      | ib    |              |            |      |
+--------------------------------------+-------+--------------+------------+------+
| 816083c1-4b8f-4a95-8646-ee4271bd2793 | 20    | controller-0 | configured | None |
| 9648a05c-96be-497f-8839-cd71c60494be | 20    | controller-1 | configured | None |
| a065976f-e489-4249-b95d-dc785f227101 | 20    | worker-0     | configured | None |
+--------------------------------------+-------+--------------+------------+------+

[sysadmin@controller-0 pxelinux.cfg(keystone_admin)]$ system host-list
+----+--------------+-------------+----------------+-------------+--------------+
| id | hostname     | personality | administrative | operational | availability |
+----+--------------+-------------+----------------+-------------+--------------+
| 1  | controller-0 | controller  | unlocked       | enabled     | available    |
| 2  | controller-1 | controller  | unlocked       | enabled     | available    |
| 3  | worker-0     | worker      | unlocked       | enabled     | available    |
| 4  | worker-1     | worker      | unlocked       | enabled     | available    |
+----+--------------+-------------+----------------+-------------+--------------+

[sysadmin@controller-0 pxelinux.cfg(keystone_admin)]$ ceph -s
  cluster:
    id:     4a5b14d7-e52f-4e27-8a1c-101c48e21c97
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum controller-0,controller-1,worker-0 (age 24m)
    mgr: controller-0(active, since 2h), standbys: controller-1
    mds:  3 up:standby
    osd: 2 osds: 1 up (since 8s), 1 in (since 8s)

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   1.5 GiB used, 197 GiB / 199 GiB avail
    pgs:

```



### 2.4 dedicatedstorage: STD (2+2+2)

#### 2.4.1 Prepare VM env and install from ISO image

```
# setup the networks for vm:
bash setup_network.sh

# Get the ISO and setup vm:
bash setup_configuration.sh -c dedicatedstorage -i ./starlingx-qemuarm64-20230526165532-cd.iso

# Install in vm:
sudo vish console dedicatedstorage-controller-0

# Make the following menu selections in the installer:
# First menu: Select ‘All-in-one Controller Configuration’
# Second menu: Select ‘Graphic Console’
```

#### 2.4.2 Bootstrap

* Login after reboot and change the password

```
export OAM_DEV=enp2s1
export OAM_NETWORK=10.10.10
export OAM_IP=3
export OAM_IP0=4
export OAM_IP1=5

export CONTROLLER0_OAM_CIDR=${OAM_NETWORK}.${OAM_IP}/24
export DEFAULT_OAM_GATEWAY=10.10.10.1
sudo ip address add $CONTROLLER0_OAM_CIDR dev $OAM_DEV
sudo ip link set up dev $OAM_DEV
sudo ip route add default via $DEFAULT_OAM_GATEWAY dev $OAM_DEV

sed -i 's/#alias/alias/' .bashrc
. ~/.bashrc

cat <<EOF > localhost.yml
system_mode: duplex

external_oam_subnet: ${OAM_NETWORK}.0/24
external_oam_gateway_address: ${DEFAULT_OAM_GATEWAY}
external_oam_floating_address: ${OAM_NETWORK}.${OAM_IP}
external_oam_node_0_address: ${OAM_NETWORK}.${OAM_IP0}
external_oam_node_1_address: ${OAM_NETWORK}.${OAM_IP1}

dns_servers:
  - 147.11.57.128
  - 8.8.8.8

offline_img_dir: /home/sysadmin/docker_img_arm64

admin_password: Li69nux*
ansible_become_pass: Li69nux*
EOF

# use scp/wget to get docker_img_arm64_20230515.tar.gz
tar xvf docker_img_arm64_20230515.tar.gz

ansible-playbook -vvv /usr/share/ansible/stx-ansible/playbooks/bootstrap.yml
```

#### 2.4.3 Configure after bootstrap

```
source /etc/platform/openrc

OAM_IF=enp2s1
MGMT_IF=enp5s0
system host-if-modify controller-0 lo -c none
IFNET_UUIDS=$(system interface-network-list controller-0 | awk '{if ($6=="lo") print $4;}')
for UUID in $IFNET_UUIDS; do
    system interface-network-remove ${UUID}
done
system host-if-modify controller-0 $OAM_IF -c platform
system interface-network-assign controller-0 $OAM_IF oam
system host-if-modify controller-0 $MGMT_IF -c platform
system interface-network-assign controller-0 $MGMT_IF mgmt
system interface-network-assign controller-0 $MGMT_IF cluster-host

# For ceph
system storage-backend-add ceph --confirmed

# unlock controller-0
system host-unlock controller-0
```

#### 2.4.4 Install controller-1 and config

* start vm for controller-1
```
sudo virsh start dedicatedstorage-controller-1
```

```
# install controller-1
system host-update 2 personality=controller
```

```
# configure controller-1
OAM_IF=enp2s1
system host-if-modify controller-1 $OAM_IF -c platform
system interface-network-assign controller-1 $OAM_IF oam
system interface-network-assign controller-1 mgmt0 cluster-host

# unlock controller-1
system host-unlock controller-1
```

#### 2.4.5 install worker and storage

```
system host-update 3 personality=worker hostname=worker-0
system host-update 4 personality=worker hostname=worker-1
system host-update 5 personality=storage hostname=storage-0
system host-update 6 personality=storage hostname=storage-1

for NODE in worker-0 worker-1; do
   system interface-network-assign $NODE mgmt0 cluster-host
done

for NODE in worker-0 worker-1; do
   system host-unlock $NODE
done

for NODE in storage-0 storage-1; do
   system interface-network-assign $NODE mgmt0 cluster-host
done

HOST=storage-0
DISKS=$(system host-disk-list ${HOST})
TIERS=$(system storage-tier-list ceph_cluster)
OSDs="/dev/sdb"
for OSD in $OSDs; do
   system host-stor-add ${HOST} $(echo "$DISKS" | grep "$OSD" | awk '{print $2}') --tier-uuid $(echo "$TIERS" | grep storage | awk '{print $2}')
done

system host-stor-list $HOST

HOST=storage-1
DISKS=$(system host-disk-list ${HOST})
TIERS=$(system storage-tier-list ceph_cluster)
OSDs="/dev/sdb"
for OSD in $OSDs; do
    system host-stor-add ${HOST} $(echo "$DISKS" | grep "$OSD" | awk '{print $2}') --tier-uuid $(echo "$TIERS" | grep storage | awk '{print $2}')
done

system host-stor-list $HOST

for STORAGE in storage-0 storage-1; do
   system host-unlock $STORAGE
done
```

#### 2.4.6 Runtime testing

* system check:
```
[sysadmin@controller-0 ~(keystone_admin)]$ system ceph-mon-list
+--------------------------------------+-------+--------------+------------+------+
| uuid                                 | ceph_ | hostname     | state      | task |
|                                      | mon_g |              |            |      |
|                                      | ib    |              |            |      |
+--------------------------------------+-------+--------------+------------+------+
| 77bab449-7a1d-4e01-a3c1-472e6ea45d6f | 20    | controller-0 | configured | None |
| 815e4dd0-4934-4780-9615-d2251a84f0d5 | 20    | storage-0    | configured | None |
| fcd64559-cd48-44cd-bb61-a3f5dc89da1e | 20    | controller-1 | configured | None |
+--------------------------------------+-------+--------------+------------+------+

[sysadmin@controller-0 ~(keystone_admin)]$ system host-list
+----+--------------+-------------+----------------+-------------+--------------+
| id | hostname     | personality | administrative | operational | availability |
+----+--------------+-------------+----------------+-------------+--------------+
| 1  | controller-0 | controller  | unlocked       | enabled     | available    |
| 2  | controller-1 | controller  | unlocked       | enabled     | available    |
| 3  | worker-0     | worker      | unlocked       | enabled     | available    |
| 4  | worker-1     | worker      | unlocked       | enabled     | available    |
| 5  | storage-0    | storage     | unlocked       | enabled     | available    |
| 6  | storage-1    | storage     | unlocked       | enabled     | available    |
+----+--------------+-------------+----------------+-------------+--------------+

[sysadmin@controller-0 ~(keystone_admin)]$ ceph -s
  cluster:
    id:     8d7e2ff8-4145-4a93-aece-06b416655343
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum controller-0,controller-1,storage-0 (age 13m)
    mgr: controller-0(active, since 2h), standbys: controller-1
    mds:  3 up:standby
    osd: 2 osds: 2 up (since 11m), 2 in (since 11m)

  data:
    pools:   0 pools, 0 pgs
    objects: 0 objects, 0 B
    usage:   3.0 GiB used, 395 GiB / 398 GiB avail
    pgs:

```