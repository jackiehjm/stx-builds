# Development Status for StarlingX on ARM

[TOC]

## Status 

### 2023-04-23

* upgrade mlnx userspace pkgs from Babak:
  * https://github.com/jackiehjm/stx-kernel/compare/master-20230202...jackiehjm:stx-kernel:jhuang0/20230423-build-arm64-update-mlnx

* Original ISO from build-image
  * http://147.11.105.121:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230423/starlingx-qemuarm64-20230423052819-cd.iso
* Change the instdev to nvme
  * http://147.11.105.121:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230423/output/starlingx-arm64-20230423052819-cd-nvme.iso
* Bundle the offline docker images:
  * http://147.11.105.121:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230423/output/starlingx-arm64-20230423052819-cd-bundle.iso
* Bundle the offline docker images and change the instdev to nvme:
  * http://147.11.105.121:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230423/output/starlingx-arm64-20230423052819-cd-bundle-nvme.iso

### 2023-04-13

* Fix kernel modules: intel-opae-fpga, intel-igb-uio, intel-iavf, intel-i40e
  * https://github.com/jackiehjm/stx-kernel/compare/master-20230202...jackiehjm:stx-kernel:jhuang0/20230413-build-arm64

### 2023-04-10

* upgrade mlnx-ofa-kernel to 5.8-1.0.1.1
  * https://github.com/jackiehjm/stx-kernel/compare/master-20230202...jackiehjm:stx-kernel:jhuang0/20230408-build-arm64-update-mlnx

* Original ISO from build-image
  http://147.11.105.121:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230410/starlingx-qemuarm64-20230410083210-cd.iso

* Change the instdev to nvme
  http://147.11.105.121:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230410/output/starlingx-arm64-20230410083210-cd-nvme.iso

* Bundle the offline docker images:
  http://147.11.105.121:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230410/output/starlingx-arm64-20230410083210-cd-bundle.iso

* Bundle the offline docker images and change the instdev to nvme:
  http://147.11.105.121:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230410/output/starlingx-arm64-20230410083210-cd-bundle-nvme.iso

### 2023-04-03

* mlnx-ofa-kernel fixed:
  * https://github.com/jackiehjm/stx-kernel/compare/master-20230202...jackiehjm:stx-kernel:jhuang0/20230315-build-arm64


* sriov-device-plugin fixed:
  * https://github.com/jackiehjm/stx-ansible-playbooks/compare/master-20230202...jackiehjm:stx-ansible-playbooks:jhuang0/20230315-build-arm64

* Use fixed fix branch to avoid the libsss_sudo issue
```
cd cgcs-root/stx/stx-puppet
git checkout -b vr/stx.8.0 vr/stx.8.0
```

### 2023-03-30

* Multus and sriov-cni fixed:
  * https://github.com/jackiehjm/stx-ansible-playbooks/compare/master-20230202...jackiehjm:stx-ansible-playbooks:jhuang0/20230315-build-arm64

### 2023-03-15

* Ceph is fixed:
  * https://github.com/jackiehjm/stx-integ/compare/master-20230202...jackiehjm:stx-integ:jhuang0/20230315-build-arm64
  * https://github.com/jackiehjm/stx-tools/compare/master-20230202...jackiehjm:stx-tools:jhuang0/20230315-build-arm64

### 2023-03-14

What was done:
* Build StarlingX master on native ARM64 (not cross build)
  * Packges removed: 
    * 14 rt pkgs (includes rt kernel and modules)
    * 14 std pkgs (includes qemu and some kenel modules)
* Tested AIO-SX (std kernel) on VM and HPE Ampere based server.
  * without:
    * storage(CEPH), Multus and SR-IOV
    * drivers for MLNX, ice and i40e NICs
    * Some of the container images are not for arm64

What next:
* Complete the AIO SX port (storage (CEPH), SR-IOV and Multus)
* AIO DX and AIO DX + 1
* Distributed cloud (AIO SX, AIO DX, and AIO DX + 1 as sub-clouds, Central region will be IA server)
* Expected completion end of H1

TODO:
1. Packages porting and fixing
   * Ceph
   * Multus
   * RT kernel
   * Drivers (kernel modules)
   * SR-IOV
   * pxe-installer
   * qemu
2. Container images porting
3. Build system fixing (build-image is broken, and a manual workaround is needed for now)
4. AIO-DX and AIO-DX + 1 testing and issue fixing
5. DC testing and issue fixing

### 2023-02-22: For MWC

* ISO image: [starlingx-arm64-20230222025752-nvme.iso](http://ala-lpggp5:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230222/starlingx-arm64-20230222025752-nvme.iso)
* Instruction: [20230222_stx_arm_iso_readme.md](../2023_MWC_Demo/20230222_stx_arm_iso_readme.md)

Note: 
* Some of the kernel drivers are missing now: e.g. mlnx-ofed, i40e
* Need to insert an NIC that available drivers can support: e.g. igb or ixgbe
* Currently it’s not fully functional, for example, multus and sriov-cni is disabled during bootstrap, and some of the container images still don’t have arm64 version to run.

## Development details

### Commits for fixes and workarounds

* Fixes and workarounds for stx-tools(7 commits):
  * https://github.com/jackiehjm/stx-tools/compare/master-20230202...jackiehjm:stx-tools:jhuang0/20230301-build-arm64

* Fixes and workdournad for build-tools(3 commits):
  * https://github.com/jackiehjm/stx-cgcs-root/compare/master-20230213...jackiehjm:stx-cgcs-root:jhuang0/20230301-build-arm64

* Fixes for packages:
  * stx-integ(11 commits):
    * https://github.com/jackiehjm/stx-integ/compare/master-20230202...jackiehjm:stx-integ:jhuang0/20230301-build-arm64
  * stx-utilities(1 commit): 
    * https://github.com/jackiehjm/stx-utilities/compare/master-20230213...jackiehjm:stx-utilities:jhuang0/20230301-build-arm64
  * stx-fault(1 commit):
    * https://github.com/jackiehjm/stx-fault/compare/master-20230213...jackiehjm:stx-fault:jhuang0/20230301-build-arm64
  * stx-containers(1 commit):
    * https://github.com/jackiehjm/stx-containers/compare/master-20230213...jackiehjm:stx-containers:jhuang0/20230301-build-arm64
  * stx-ha(2 commits):
    * https://github.com/jackiehjm/stx-ha/compare/master-20230213...jackiehjm:stx-ha:jhuang0/20230301-build-arm64
  * stx-kernel(8 commits):
    * https://github.com/jackiehjm/stx-kernel/compare/master-20230202...jackiehjm:stx-kernel:jhuang0/20230301-build-arm64 
  * stx-metal(2 commits):
    * https://github.com/jackiehjm/stx-metal/compare/master-20230213...jackiehjm:stx-metal:jhuang0/20230301-build-arm64
  * stx-ansible-playbooks(3 commits):
    * https://github.com/jackiehjm/stx-ansible-playbooks/compare/master-20230202...jackiehjm:stx-ansible-playbooks:jhuang0/20230301-build-arm64

* Fixes and workarounds for LAT(2 commits):
  * https://github.com/jackiehjm/wrl-meta-lat/compare/wr-10.cd-20230210...jackiehjm:wrl-meta-lat:jhuang0/20230301-build-arm64
  * Built SDK on ARM64 server with the commits: 
    * http://ala-lpggp5:5088/3_open_source/stx/images-arm64/lat-sdk/lat-sdk-build_20230301/wrlinux-graphics-10.23.09.0-glibc-aarch64-qemuarm64-container-base-sdk.sh

### How to build (Native build on ARM server)

#### Install required packages

* Install Docker Engine:
  * ref: https://docs.docker.com/engine/install/debian/

```
sudo apt-get remove docker docker.io containerd runc

sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

* Add user to docker group
```
sudo usermod -aG docker $(id -un) && newgrp docker
```

* Install helm, minikube and repo

```
git clone https://github.com/jackiehjm/stx-builds.git -b jhuang0/20230426-build-arm64
./stx-builds/build_stx_debian/build_stx_host_prepare.sh -w <work_space_dir> -a arm64
```

#### Get the stx-builds script and build
```
git clone https://github.com/jackiehjm/stx-builds.git -b jhuang0/20230426-build-arm64

./stx-builds/build_stx_debian/build_stx_debian.sh -w <work_space_dir> -a arm64 -b r/stx.8.0 -p <parralel_build_num>
```

The build-image will always fail, do the following workaround after build-image fails:

```
cd <work_space_dir>
source env.prj-stx-deb
cd src/stx-tools
source import-stx

stx shell --container lat

# inside the LAT pod
cd /localdisk
. /opt/LAT/SDK/environment-setup-cortexa57-wrs-linux
appsdk --log-dir log genimage lat.yaml
```

### Packages porting

#### Failed packages and fix status

| #   | STD/RT | Pkg name                            | Owner  | Status      | Comment                                            |
| --- | ------ | ----------------------------------- | ------ | ----------- | -------------------------------------------------- |
| 1   | STD    | stx-sdo-helm                        | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 2   | STD    | istio-helm                          | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 3   | STD    | kiali-helm                          | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 4   | STD    | stx-istio-helm                      | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 5   | STD    | stx-kubevirt-app-helm               | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 6   | STD    | stx-oran-o2-helm                    | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 7   | STD    | stx-security-profiles-operator-helm | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 8   | STD    | stx-sriov-fec-operator-helm         | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 9   | STD    | stx-sts-silicom-helm                | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 10  | STD    | stx-audit-helm                      | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 11  | STD    | stx-cert-manager-helm               | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 12  | STD    | registry-token-server               | jackie | [Fixed][12] |                                                    |
| 13  | STD    | fm-mgr                              | jackie | [Fixed][13] |                                                    |
| 14  | STD    | sm                                  | jackie | Fixed       | Pass after 15 fixed                                |
| 15  | STD    | sm-common                           | jackie | [Fixed][15] |                                                    |
| 16  | STD    | sm-db                               | jackie | Fixed       | Pass after 15 fixed                                |
| 17  | STD    | gpu-operator                        | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 18  | STD    | grub-efi                            | jackie | [Fixed][19] |                                                    |
| 19  | STD    | grub2                               | jackie | [Fixed][19] |                                                    |
| 20  | STD    | armada                              | jackie | Fixed       | Pass after 21, 22, 24 fixed                        |
| 21  | STD    | armada-helm-toolkit                 | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 22  | STD    | chartmuseum                         | jackie | [Fixed][22] | Ver upgraded 0.12.0 -> 0.13.0, not sure the impact |
| 23  | STD    | crictl                              | jackie | [Fixed][23] |                                                    |
| 24  | STD    | helm                                | jackie | [Fixed][24] |                                                    |
| 25  | STD    | kubernetes-1.21.8                   | jackie | [Fixed][25] |                                                    |
| 26  | STD    | kubernetes-1.22.5                   | jackie | [Fixed][25] |                                                    |
| 27  | STD    | kubernetes-1.23.1                   | jackie | [Fixed][25] |                                                    |
| 28  | STD    | kubernetes-1.24.4                   | jackie | [Fixed][25] |                                                    |
| 29  | STD    | kubectl-cert-manager                | jackie | [Fixed][29] |                                                    |
| 30  | STD    | kpatch                              | litao  | removed     | Out of scope[arm64 not supported][52]              |
| 31  | STD    | qemu                                | jackie | removed     | Should be able to remove                           |
| 32  | STD    | bnxt-en                             | jackie | removed     |                                                    |
| 33  | STD    | i40e                                | jackie | Fixed       |                                                    |
| 34  | STD    | i40e-cvl-2.54                       | jackie | Fixed       |                                                    |
| 35  | STD    | iavf                                | jackie | Fixed       |                                                    |
| 36  | STD    | iavf-cvl-2.54                       | jackie | Fixed       |                                                    |
| 37  | STD    | ice                                 | jackie | removed     |                                                    |
| 38  | STD    | ice-cvl-2.54                        | jackie | removed     |                                                    |
| 39  | STD    | igb-uio                             | jackie | Fixed       |                                                    |
| 40  | STD    | kmod-opae-fpga-driver               | jackie | Fixed       |                                                    |
| 41  | STD    | iqvlinux                            | jackie | removed     |                                                    |
| 42  | STD    | mlnx-ofed-kernel                    | jackie | Fixed       |                                                    |
| 43  | STD    | qat1.7.l                            | jackie | removed     |                                                    |
| 44  | STD    | linux                               | jackie | [Fixed][44] |                                                    |
| 45  | STD    | kpatch-prebuilt                     | litao  | removed     | Out of scope[arm64 not supported][52]              |
| 46  | STD    | pxe-network-installer               | jackie | [Fixed][46] |                                                    |
| 47  | STD    | mtce                                | jackie | Fixed       | Pass after 13 fixed                                |
| 48  | STD    | mtce-common                         | jackie | Fixed       | Pass after 13 fixed                                |
| 49  | STD    | metrics-server-helm                 | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 50  | STD    | stx-metrics-server-helm             | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 51  | STD    | monitor-helm                        | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 52  | STD    | monitor-helm-elastic                | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 53  | STD    | stx-monitor-helm                    | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 54  | STD    | stx-nginx-ingress-controller-helm   | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 55  | STD    | stx-oidc-auth-helm                  | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 56  | STD    | openstack-helm                      | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 57  | STD    | openstack-helm-infra                | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 58  | STD    | stx-openstack-helm                  | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 59  | STD    | stx-openstack-helm-fluxcd           | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 60  | STD    | platform-helm                       | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 61  | STD    | stx-platform-helm                   | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 62  | STD    | portieris-helm                      | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 63  | STD    | stx-portieris-helm                  | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 64  | STD    | stx-ptp-notification-helm           | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 65  | STD    | stx-snmp-helm                       | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 66  | STD    | opae-sdk                            | jackie | Removed     | Should be able to remove                           |
| 67  | STD    | pcm                                 | litao  | Removed     | Out of scope,[intel cpu only][50], [STX vRAN][51]  |
| 68  | STD    | stx-vault-helm                      | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 69  | STD    | vault-helm                          | jackie | Fixed       | Pass after 22, 24 fixed                            |
| 70  | RT     | bnxt-en                             | jackie | Removed     |                                                    |
| 71  | RT     | i40e                                | jackie | Removed     |                                                    |
| 72  | RT     | i40e-cvl-2.54                       | jackie | Removed     |                                                    |
| 73  | RT     | iavf                                | jackie | Removed     |                                                    |
| 74  | RT     | iavf-cvl-2.54                       | jackie | Removed     |                                                    |
| 75  | RT     | ice                                 | jackie | Removed     |                                                    |
| 76  | RT     | ice-cvl-2.54                        | jackie | Removed     |                                                    |
| 77  | RT     | igb-uio                             | jackie | Removed     |                                                    |
| 78  | RT     | kmod-opae-fpga-driver               | jackie | Removed     |                                                    |
| 79  | RT     | iqvlinux                            | jackie | Removed     |                                                    |
| 80  | RT     | mlnx-ofed-kernel                    | jackie | Removed     |                                                    |
| 81  | RT     | qat1.7.l                            | jackie | Removed     |                                                    |
| 82  | RT     | linux-rt                            | jackie | Removed     |                                                    |
| 83  | RT     | kpatch-prebuilt                     | jackie | Removed     |                                                    |


### Container images porting

#### Pulled and used image list:

| #   | Image name                                      | Available for ARM(Y/N)? | Owner  | Status | Comment                                                |
| --- | ----------------------------------------------- | ----------------------- | ------ | ------ | ------------------------------------------------------ |
| 1   | docker.io/fluxcd/helm-controller:v0.27.0        | Y                       |        | NA     |                                                        |
| 2   | docker.io/fluxcd/source-controller:v0.32.1      | Y                       |        | NA     |                                                        |
| 3   | docker.io/starlingx/armada-image:stx.7.0-v1.0.0 | N                       | jackie | Done   | [docker.io/stx4arm/armada-image][55]                   |
| 4   | ghcr.io/helm/tiller:v2.16.9                     | N                       | jackie | Done   | [docker.io/stx4arm/tiller:v2.16.9][56]                 |
| 5   | ghcr.io/k8snetworkplumbingwg/multus-cni:v3.9.2  | Y                       |        | NA     |                                                        |
| 6   | ghcr.io/k8snetworkplumbingwg/sriov-cni:v2.6.3   | N                       | jackie | Done   | [docker.io/stx4arm/sriov-cni][58]                      |
| 7   | k8s.gcr.io/coredns/coredns:v1.8.6               | N                       |        | todo   | should be supported.<br />need to find the alternative |
| 8   | k8s.gcr.io/ingress-nginx/controller:v1.1.1      | Y                       |        |        |                                                        |
| 9   | k8s.gcr.io/kube-apiserver:v1.24.4               | Y                       |        |        |                                                        |
| 10  | k8s.gcr.io/kube-controller-manager:v1.24.4      | Y                       |        |        |                                                        |
| 11  | k8s.gcr.io/kube-proxy:v1.24.4                   | Y                       |        |        |                                                        |
| 12  | k8s.gcr.io/kube-scheduler:v1.24.4               | Y                       |        |        |                                                        |
| 13  | k8s.gcr.io/pause:3.7                            | Y                       |        |        |                                                        |
| 14  | quay.io/calico/kube-controllers:v3.24.0         | Y                       |        |        |                                                        |
| 15  | quay.io/calico/node:v3.24.0                     | Y                       |        |        |                                                        |
| 16  | quay.io/jetstack/cert-manager-acmesolver:v1.7.1 | Y                       |        |        |                                                        |
| 17  | quay.io/jetstack/cert-manager-cainjector:v1.7.1 | Y                       |        |        |                                                        |
| 18  | quay.io/jetstack/cert-manager-controller:v1.7.1 | Y                       |        |        |                                                        |
| 19  | quay.io/jetstack/cert-manager-ctl:v1.7.1        | Y                       |        |        |                                                        |
| 20  | gcr.io/kubebuilder/kube-rbac-proxy:v0.11.0      | Y                       |        |        |                                                        |

#### Pulled but not used image list:

| #   | Image name                                                        | For ARM(Y/N)? | Owner  | Status | Comment                                          |
| --- | ----------------------------------------------------------------- | ------------- | ------ | ------ | ------------------------------------------------ |
| 1   | docker.io/starlingx/n3000-opae:stx.8.0-v1.0.2                     | N             |        |        |                                                  |
| 2   | docker.io/wind-river/cloud-platform-deployment-manager:WRCP_22.12 | N             |        |        |                                                  |
| 3   | docker.io/wind-river/dm-monitor:WRCP_22.12-v1.0.0                 | N             |        |        |                                                  |
| 4   | quay.io/stackanetes/kubernetes-entrypoint:v0.3.1                  | N             | jackie | Done   | [docker.io/stx4arm/kubernetes-entrypoint][57]    |
| 5   | ghcr.io/k8snetworkplumbingwg/sriov-network-device-plugin:v3.5.1   | N             | jackie | Done   | [stx4arm/sriov-network-device-plugin:v3.5.1][59] |
| 6   | k8s.gcr.io/defaultbackend-amd64:1.5                               | N             | jackie | DOne   | k8s.gcr.io/defaultbackend-arm64                  |
| 7   | k8s.gcr.io/etcd:3.5.3-0                                           | Y             |        |        |                                                  |
| 8   | k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1              | Y             |        |        |                                                  |
| 9   | quay.io/calico/cni:v3.24.0                                        | Y             |        |        |                                                  |
| 10  | quay.io/k8scsi/snapshot-controller:v2.0.0-rc2                     | N             |        |        |                                                  |

[12]: https://github.com/jackiehjm/stx-containers/commit/c5363249cca07f76cdd6959d2f8471a7f4739cc9
[15]: https://github.com/jackiehjm/stx-ha/compare/master...jackiehjm:stx-ha:jhuang0/20230208-build-arm64
[13]: https://github.com/jackiehjm/stx-fault/commit/8ba2dfdfd711531d0b09454c655889910d310902
[19]: https://github.com/jackiehjm/stx-integ/commit/ba578c673cdd7679050fe64cf8031b746fb4502a
[22]: https://github.com/jackiehjm/stx-integ/commit/c46be4067969e938fe572f86504e801e09c030d2
[23]: https://github.com/jackiehjm/stx-integ/commit/dd67a23edbd63375cb8c5b85690c8c866ccb1710
[24]: https://github.com/jackiehjm/stx-integ/commit/00e4140b92b06ece1c4cc4441afee9df55c2be9d
[25]: https://github.com/jackiehjm/stx-integ/commit/a27b2651d19e4e0c0862a237544b85d911b327ca
[29]: https://github.com/jackiehjm/stx-integ/commit/8fc3b3ef234bfd6b295e7ea5db8f2274917e1766
[44]: https://github.com/jackiehjm/stx-kernel/commit/c408447cb9206e12343bc98746cc3999b278c130
[46]: https://github.com/jackiehjm/stx-metal/commit/8fd372b2c6b771b9f1f34f7e12cd435110cfbfbc
[50]: https://github.com/intel/pcm
[51]: https://docs.starlingx.io/usertasks/kubernetes/vran-tools-2c3ee49f4b0b.html
[52]: https://github.com/dynup/kpatch/#supported-architectures
[53]: https://github.com/k8snetworkplumbingwg/sriov-cni
[54]: https://github.com/jessestuart/tiller-multiarch
[55]: https://hub.docker.com/repository/docker/stx4arm/armada-image
[56]: https://hub.docker.com/repository/docker/stx4arm/tiller
[57]: https://hub.docker.com/repository/docker/stx4arm/kubernetes-entrypoint/general
[58]: https://hub.docker.com/repository/docker/stx4arm/sriov-cni/general
[59]: https://hub.docker.com/repository/docker/stx4arm/sriov-network-device-plugin/general