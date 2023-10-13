# Development Status for StarlingX on ARM

[TOC]

## Goals (What needs to be done?)

* StarlingX fully support ARM64 artichecture on selected server (Ampere Altra based)

* What needs to be done:
  * Enable native build on ARM64 server.
    * Enhance the build system to support both x86-64 and ARM64.
    * Re-build LAT-SDK (tools for building image) for ARM64.
    * Provide ISO image with automated installer as x86-64.
  * Packages porting for ARM64:
    * 80+ need source code porting.
    * 1400+ need to re-build.
    * Support both std and rt kernel.
  * Container images re-build for ARM64:
    * 150+ container images, 30+ need to re-build.
  * Features adjustment for ARM64:
    * ISO/PXE installer: ARM64 server doesn't suppport legacy_bios and syslinux, use only grub-efi.
    * Secure boot: current design is for x86-64 only, need to re-design for ARM64. 
    * Other features.
  * StarlingX community contribution:
    * ARM and Ampere contribute 6 servers to the community: 2 for build, 4 for runtime testing
    * Contribute all source codes changes: 15+ repos
    * Pre-built packages push to stalingx mirror (https://mirror.starlingx.cengn.ca/mirror/starlingx/)
    * LAT-SDK for ARM64 push to starlingx mirror (http://mirror.starlingx.cengn.ca/mirror/lat-sdk/) 
    * All container images for ARM64 push to dockerhub (https://hub.docker.com/u/starlingx)
  * Support all StarlingX deplyment configurations:
    * All-in-one Simplex
    * All-in-one Duplex
    * All-in-one Duplex + Workers
    * Standard with Storage Cluster on Controller Nodes
    * Standard with Storage Cluster on dedicated Storage Nodes
    * Distributed Cloud

## Overall status (What was done and what’s next?)

* Ongoing reviews:
  * https://review.opendev.org/q/topic:arm64/20230725-stx-master-native

* What was done by 2023-10-08
  * [Done] Build StarlingX 8 on native ARM (not cross build).
  * [95% Done] Packages and container images porting.
    * Failed pkg: ice modules, qemu
    * Skipped feature: secure boot
  * [Done] Deliveries: ISOs and offline container images
    * Drop 1: at the end of Feb for MWC demo
      * Based on stx-8.0
      * AIO-SX without ceph, multus and SRIOV
    * Drop 2: at the end of Apr for Fujitsu (Export review completed)
      * Based on stx-8.0
      * AIO-SX, AIO-DX
    * Drop 3: at the end of Jun
      * Based on stx-8.0
      * AIO-SX, AIO-DX + worker, STD (2+2+2), DC
    * Drop 4: at the end of July
      * Based on stx master 20230625
      * [Both STD and RT kernel] AIO-SX, AIO-DX + worker, STD (2+2+2), DC 
  * [Done] Deployment verification.
    * AIO-SX: Bare metal and VM
    * AIO-SX(LL): Bare metal and VM
    * AIO-DX: Bare metal and VM
    * AIO-DX(LL): Bare metal and VM
    * AIO-DX + worker: Bare metal and VM
    * STD (2+2): VM
    * STD (2+2+2): VM
    * DC (AIO-DX for Central + 2 sub-cloud with AIO-SX): VM
    * DC (AIO-DX-LL for Central + 2 sub-cloud with AIO-SX-LL): VM

* What real HW has been tested?
  * HPE ProLiant RL300 Gen11​
    * CPU: Ampere(R) Altra(R) Processor 3000MHz 80/80 cores​
    * Memory: 16G(DDR4 3200MHz) x 16 = 256G​
    * Disk: NVMe SSD 2T​
    * Network: Mellanox MT2894 Family [ConnectX-6 Lx] Adapter​
  * SuperMicro R12SPD-A (only tested with AIO-SX for now)​
    * CPU: Ampere(R) Altra(R) Processor 3000MHz 80/80 cores​
    * Memory: 32G(DDR4 3200MHz) x 16 = 512G​
    * Disk: NVMe SSD 1T​
    * Network: Mellanox Technologies MT27710 Family [ConnectX-4 Lx]​
    * Accelerator: NVIDIA A100X Converged Accelerator​
Notes: There is a known issue for SuperMicro, which needs workaround on ISO installation.

* What next
  * [Done] (2023-07 ~ 2023-08) Enhance the build system to support both x86-64 and ARM64.
  * [In-Progress] (2023-08 ~ 2023-11) Write StarlingX specifications (HLD) for ARM64 implementations and get it approved.
  * [In-Progress] (2023-10 ~ 2023-12) Work with community with all POC level codes and make them product level, review and push to community.
  * [In-Progress] (2023-07 ~ 2023-12) contribute 6 servers to the community and setup the CICD workflow.
  * [In-Progress] (2023-10 ~ 2023-12) DOC: provide documentations about StarlingX on ARM.​
  * [In-Progress] (2023-10 ~ 2024-02) Joint demos with RAN application vendors for MWC24.
  * [Todo] (2023-11 ~ 2023-12) Goden Testsuite for the RAN application on StarlingX on ARM.
  * [Todo] (2023-12 or 2024) Pre-built packages push to stalingx mirror (https://mirror.starlingx.cengn.ca/mirror/starlingx/)
  * [Todo] (2023-12 or 2024) LAT-SDK for ARM64 push to starlingx mirror (http://mirror.starlingx.cengn.ca/mirror/lat-sdk/) 
  * [Todo] (2023-12 or 2024) All container images for ARM64 push to dockerhub (https://hub.docker.com/u/starlingx)
  * [todo] (2023-12 or 2024) remaining packages source code porting: ice, qemu
  * [Todo] (2023-12 or 2024) Secure boot and other features re-design or adjustment.

Notes: The remaining work items are highly dependent on the interaction with the community, the community's reaction has lagged behind our expectation, and we have difficulties in moving on the Spec/HLD review and the CICD workflow, it's likely that some of items will be delayed to next year.​

## Detail Plan and Status (What was done and what’s next?)

### Phase 1 (2023-01 ~ 2023-02):
    
* [Done] Enable bative build system on HPE RL300 Ampere server (POC level)
* [Done] Re-build LAT-SDK for ARM64 (POC level)
* [Done] 40+ packages source code porting (POC level)
* [Done] 10 container images re-built for ARM64 (POC level)
* [Done] ISO installer adjustment for ARM64 (POC level)
* [Done] Provide ISO image for MWC demo (Demo with AIO-SX deployment on a HPE RL300 server)

Known issues and limitations:
* Lack of RT kernel (for lowlatency profile)
* Lack of kernel modules: mlnx-ofed-kernel, i40e, ice, iqvlinux, qat
* Lack of Ceph
* Lack of qemu
* Lack of secure boot feature
* build-image needs manual workaroud

### Phase 2 (2023-03 ~ 2023-06):

* [Done] Additional 20+ packages source code porting (POC level)
* [Done] Additional 4 containere images re-build (POC level)
* [Done] PXE installer adjustment for ARM64 (POC level)
* [Done] Deployment verification.
  * AIO-SX: Bare metal and VM
  * AIO-DX: Bare metal and VM
  * AIO-DX + worker: Bare metal and VM
  * STD (2+2): VM
  * STD (2+2+2): VM
  * DC (AIO-DX for Central + 2 sub-cloud with AIO-SX): VM
* [Done] StarlingX community contribution kickstart:
  * Create user story and tasks.
  * Start the servers contirbution discussion.
  
Known issues and limitations:
* Lack of RT kernel (for lowlatency profile)
* Lack of kernel modules: ice, iqvlinux, qat
* Lack of qemu
* Lack of secure boot feature

Notes: POC level means that there are many hardcodes and workarounds, not good for upstream

### Phase 3 (2023-07 ~ 2023-12):

* [Done] (by the end of 2023-07) remaining packages source code porting: RT kernel
* [Done] (by the end of 2023-07) Deployment verification.
  * AIO-SX(lowlatency): Bare metal and VM
  * AIO-DX(lowlatency): Bare metal and VM
  * AIO-DX(lowlatency) + worker: Bare metal and VM
  * STD (2+1): Bare metal
  * DC (AIO-DX for Central + 2 sub-cloud with AIO-SX): VM
  * DC (AIO-DX-LL for Central + 2 sub-cloud with AIO-SX-LL): VM
* [In-Progress] (2023-07 ~ 2023-08) Enhance the build system to support both x86-64 and ARM64.
* [In-Progress] (2023-08) Write StarlingX specifications (HLD) for ARM64 implementations.
* [In-Progress] (2023-08 ~ 2023-10) Work with community with all POC level codes and make them product level, review and push to community.
* [In-Progress] (2023-07 ~ 2023-12) contribute 6 servers to the community and setup the CICD workflow.
* [Todo] (2023-10 ~ 2023-12) Pre-built packages push to stalingx mirror (https://mirror.starlingx.cengn.ca/mirror/starlingx/)
* [Todo] (2023-10 ~ 2023-12) LAT-SDK for ARM64 push to starlingx mirror (http://mirror.starlingx.cengn.ca/mirror/lat-sdk/) 
* [Todo] (2023-10 ~ 2023-12) All container images for ARM64 push to dockerhub (https://hub.docker.com/u/starlingx)
* [Todo] (2023-10 ~ 2023-12) DOC: provide documentaions about StarlingX on ARM.
* [todo] (2023-10 ~ 2023-12) remaining packages source code porting: ice, qemu
* [Todo] (2023-12 or 2024) Secure boot and other features re-design or adjustment.

CICD plan (draft):
* [In-Progress] contribute 6 servers to the community and setup the CICD workflow.
  * [In-Progress](by the end of 2023-08) Get 6 servers ready from Ampere and send to StarlingX community(WindRiver Lab).
  * [In-Progress](by the end of 2023-08) Get the CICD setup and deploy docs from StarlingX.
    * who will help on the CICD setup on ARM platform?
    * If there is any concret plan on setuping CICD on ARM?
    * CICD related repos/links that can be ref
    * How can we access to the CICD env for ARM developers from WindRiver and Arm
  * [todo](by the end of 2023-10) Setup and deploy CICD tools on the 6 servers hosted by StarlingX community(WindRiver Lab)
  * [todo](by the end of 2023-12) Test and ensure the CICD workflow work as expected

## Development summary

* User Story: https://storyboard.openstack.org/#!/story/2010739

* Porting:
  * Almost completed.
  * Rebased all to master 20230625
  * RT kernel works after rebase
  * Only few kenel modules that might not be supported on ARM
  * OPAE-SDK: for Intel FPGA only
  * PCM: for Intel only
  * qemu: I know that it will be upgrade to newer version, so I will do that after the upgrading complete

* Implementation Design:
  * Part 1: for most of the pkgs
    * Fix the deb rules to support multiarch:
      * e.g. replace hardcoded arch string with variable DEB_HOST_ARCH
  * Part 2: for package list file, e.g. debian_pkg_dirs, debian_iso_image.inc, base-bullseye.lst
    * Need to add arch specific lists
  * part 3: build-tools to support multiarch, add logic to remove the hardcodes
  * part 4: ISO image only support EFI mode, no lagacy mode (remove syslinux)
  * part 5: secure boot, disable for now, need help from security expert.
  * part 6: LAT-SDK: need to add logic to remove the hardcodes and support both x86 and arm64
  * part 7: container-images: some images only have x86 version, need to re-build for arm64 and push to differnet place, how to handle different images url

## Development details

### Commits for fixes and workarounds

* Reviews: https://review.opendev.org/q/topic:arm64/20230725-stx-master-native

* Fixes and workarounds for stx-tools(22 commits):
  * https://github.com/starlingx/tools/compare/master...jackiehjm:stx-tools:arm64/20230725-stx-master-native

* Fixes and workdournad for cgcs-root/build-tools(4 commits):
  * https://github.com/starlingx/root/compare/master...jackiehjm:stx-cgcs-root:arm64/20230725-stx-master-native

* Fixes for packages:
  * stx-integ(14 commits):
    * https://github.com/starlingx/integ/compare/master...jackiehjm:stx-integ:arm64/20230725-stx-master-native
  * stx-utilities(1 commit):
    * https://github.com/starlingx/utilities/compare/master...jackiehjm:stx-utilities:arm64/20230725-stx-master-native
  * stx-fault(1 commit):
    * https://github.com/starlingx/fault/compare/master...jackiehjm:stx-fault:arm64/20230725-stx-master-native
  * stx-containers(1 commit):
    * https://github.com/starlingx/containers/compare/master...jackiehjm:stx-containers:arm64/20230725-stx-master-native
  * stx-ha(2 commits):
    * https://github.com/starlingx/ha/compare/master...jackiehjm:stx-ha:arm64/20230725-stx-master-native
  * stx-kernel(19 commits):
    * https://github.com/starlingx/kernel/compare/master...jackiehjm:stx-kernel:arm64/20230725-stx-master-native
  * stx-metal(6 commits):
    * https://github.com/starlingx/metal/compare/master...jackiehjm:stx-metal:arm64/20230725-stx-master-native
  * stx-ansible-playbooks(6 commits):
    * https://github.com/starlingx/ansible-playbooks/compare/master...jackiehjm:stx-ansible-playbooks:arm64/20230725-stx-master-native
  * stx-config(1 commit):
    * https://github.com/starlingx/config/compare/master...jackiehjm:stx-config:arm64/20230725-stx-master-native
  * stx-puppet(1 commit):
    * https://github.com/starlingx/stx-puppet/compare/master...jackiehjm:stx-puppet:arm64/20230725-stx-master-native
  * stx-nginx-ingress-controller-armada-app(1 commit):
    * https://github.com/starlingx/nginx-ingress-controller-armada-app/compare/master...jackiehjm:stx-nginx-ingress-controller-armada-app:arm64/20230725-stx-master-native
  * stx-app-istio
    * https://github.com/jackiehjm/stx-app-istio/compare/master...arm64/20230725-stx-master-native
  * stx-virt
    * https://github.com/jackiehjm/stx-virt/compare/master...arm64/20230725-stx-master-native

* Fixes and workarounds for LAT(5 commits):
  * https://github.com/jackiehjm/wrl-meta-lat/compare/wr-10.cd-20230210...jackiehjm:wrl-meta-lat:arm64/20230725-stx-master-native
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
git clone https://github.com/jackiehjm/stx-builds.git
./stx-builds/build_stx_debian/build_stx_host_prepare.sh -w <work_space_dir> -a arm64
```

#### Get the stx-builds script and build
```
git clone https://github.com/jackiehjm/stx-builds.git

./stx-builds/build_stx_debian/build_stx_debian.sh -w <work_space_dir> -a arm64 -p <parralel_build_num>
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
| 71  | RT     | i40e                                | jackie | Fixed       |                                                    |
| 72  | RT     | i40e-cvl-2.54                       | jackie | Fixed       |                                                    |
| 73  | RT     | iavf                                | jackie | Fixed       |                                                    |
| 74  | RT     | iavf-cvl-2.54                       | jackie | Fixed       |                                                    |
| 75  | RT     | ice                                 | jackie | Removed     |                                                    |
| 76  | RT     | ice-cvl-2.54                        | jackie | Removed     |                                                    |
| 77  | RT     | igb-uio                             | jackie | Fixed       |                                                    |
| 78  | RT     | kmod-opae-fpga-driver               | jackie | Fixed       |                                                    |
| 79  | RT     | iqvlinux                            | jackie | Removed     |                                                    |
| 80  | RT     | mlnx-ofed-kernel                    | jackie | Fixed       |                                                    |
| 81  | RT     | qat1.7.l                            | jackie | Removed     |                                                    |
| 82  | RT     | linux-rt                            | jackie | Fixed       | Fixed after upgrade to 5.10.177                    |


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
| 8   | k8s.gcr.io/ingress-nginx/controller:v1.1.1      | Y                       |        | NA     |                                                        |
| 9   | k8s.gcr.io/kube-apiserver:v1.24.4               | Y                       |        | NA     |                                                        |
| 10  | k8s.gcr.io/kube-controller-manager:v1.24.4      | Y                       |        | NA     |                                                        |
| 11  | k8s.gcr.io/kube-proxy:v1.24.4                   | Y                       |        | NA     |                                                        |
| 12  | k8s.gcr.io/kube-scheduler:v1.24.4               | Y                       |        | NA     |                                                        |
| 13  | k8s.gcr.io/pause:3.7                            | Y                       |        | NA     |                                                        |
| 14  | quay.io/calico/kube-controllers:v3.24.0         | Y                       |        | NA     |                                                        |
| 15  | quay.io/calico/node:v3.24.0                     | Y                       |        | NA     |                                                        |
| 16  | quay.io/jetstack/cert-manager-acmesolver:v1.7.1 | Y                       |        | NA     |                                                        |
| 17  | quay.io/jetstack/cert-manager-cainjector:v1.7.1 | Y                       |        | NA     |                                                        |
| 18  | quay.io/jetstack/cert-manager-controller:v1.7.1 | Y                       |        | NA     |                                                        |
| 19  | quay.io/jetstack/cert-manager-ctl:v1.7.1        | Y                       |        | NA     |                                                        |
| 20  | gcr.io/kubebuilder/kube-rbac-proxy:v0.11.0      | Y                       |        | NA     |                                                        |

#### Pulled but not used image list:

| #   | Image name                                                        | For ARM(Y/N)? | Owner  | Status | Comment                                          |
| --- | ----------------------------------------------------------------- | ------------- | ------ | ------ | ------------------------------------------------ |
| 1   | docker.io/starlingx/n3000-opae:stx.8.0-v1.0.2                     | N             |        |        |                                                  |
| 2   | docker.io/wind-river/cloud-platform-deployment-manager:WRCP_22.12 | N             |        |        |                                                  |
| 3   | docker.io/wind-river/dm-monitor:WRCP_22.12-v1.0.0                 | N             |        |        |                                                  |
| 4   | quay.io/stackanetes/kubernetes-entrypoint:v0.3.1                  | N             | jackie | Done   | [docker.io/stx4arm/kubernetes-entrypoint][57]    |
| 5   | ghcr.io/k8snetworkplumbingwg/sriov-network-device-plugin:v3.5.1   | N             | jackie | Done   | [stx4arm/sriov-network-device-plugin:v3.5.1][59] |
| 6   | k8s.gcr.io/defaultbackend-amd64:1.5                               | N             | jackie | Done   | k8s.gcr.io/defaultbackend-arm64                  |
| 7   | k8s.gcr.io/etcd:3.5.3-0                                           | Y             |        | NA     |                                                  |
| 8   | k8s.gcr.io/ingress-nginx/kube-webhook-certgen:v1.1.1              | Y             |        | NA     |                                                  |
| 9   | quay.io/calico/cni:v3.24.0                                        | Y             |        | NA     |                                                  |
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

## Status History 

### 2023-05-26

* https://github.com/jackiehjm/wrl-meta-lat/compare/wr-10.cd-20230210...jackiehjm:wrl-meta-lat:arm64/20230515-stx80-native
* https://github.com/jackiehjm/stx-config/compare/r/stx.8.0...jackiehjm:stx-config:arm64/20230515-stx80-native 
* https://github.com/jackiehjm/stx-puppet/compare/r/stx.8.0...jackiehjm:stx-puppet:arm64/20230515-stx80-native

### 2023-05-17

* Discussion on StarlingX non openstack distro meeting: https://etherpad.opendev.org/p/stx-distro-other

### 2023-05-15

* User Story: https://storyboard.openstack.org/#!/story/2010739


#### Commits for fixes re-work based on stx.8.0

* Fixes and workarounds for stx-tools(20 commits):
  * https://github.com/jackiehjm/stx-tools/compare/r/stx.8.0...jackiehjm:stx-tools:arm64/20230515-stx80-native

* Fixes and workdournad for cgcs-root/build-tools(3 commits):
  * https://github.com/jackiehjm/stx-cgcs-root/compare/r/stx.8.0...jackiehjm:stx-cgcs-root:arm64/20230515-stx80-native

* Fixes for packages:
  * stx-integ(11 commits):
    * https://github.com/jackiehjm/stx-integ/compare/r/stx.8.0...jackiehjm:stx-integ:arm64/20230515-stx80-native
  * stx-utilities(1 commit):
    * https://github.com/jackiehjm/stx-utilities/compare/r/stx.8.0...jackiehjm:stx-utilities:arm64/20230515-stx80-native
  * stx-fault(1 commit):
    * https://github.com/jackiehjm/stx-fault/compare/r/stx.8.0...jackiehjm:stx-fault:arm64/20230515-stx80-native
  * stx-containers(1 commit):
    * https://github.com/jackiehjm/stx-ha/compare/r/stx.8.0...jackiehjm:stx-ha:arm64/20230515-stx80-native
  * stx-ha(2 commits):
    * https://github.com/jackiehjm/stx-ha/compare/r/stx.8.0...jackiehjm:stx-ha:arm64/20230515-stx80-native
  * stx-kernel(17 commits):
    * https://github.com/jackiehjm/stx-kernel/compare/r/stx.8.0...jackiehjm:stx-kernel:arm64/20230515-stx80-native
  * stx-metal(2 commits):
    * https://github.com/jackiehjm/stx-metal/compare/r/stx.8.0...jackiehjm:stx-metal:arm64/20230515-stx80-native
  * stx-ansible-playbooks(3 commits):
    * https://github.com/jackiehjm/stx-ansible-playbooks/compare/r/stx.8.0...jackiehjm:stx-ansible-playbooks:arm64/20230515-stx80-native

* Fixes and workarounds for LAT(2 commits):
  * https://github.com/jackiehjm/wrl-meta-lat/compare/wr-10.cd-20230210...jackiehjm:wrl-meta-lat:jhuang0/20230301-build-arm64
  * Built SDK on ARM64 server with the commits:
    * http://ala-lpggp5:5088/3_open_source/stx/images-arm64/lat-sdk/lat-sdk-build_20230301/wrlinux-graphics-10.23.09.0-glibc-aarch64-qemuarm64-container-base-sdk.sh

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

#### Commits for fixes and workarounds

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

### 2023-02-22: For MWC

* ISO image: [starlingx-arm64-20230222025752-nvme.iso](http://ala-lpggp5:5088/3_open_source/stx/images-arm64/build-img-gigabyte_20230222/starlingx-arm64-20230222025752-nvme.iso)
* Instruction: [20230222_stx_arm_iso_readme.md](../2023_MWC_Demo/20230222_stx_arm_iso_readme.md)

Note: 
* Some of the kernel drivers are missing now: e.g. mlnx-ofed, i40e
* Need to insert an NIC that available drivers can support: e.g. igb or ixgbe
* Currently it’s not fully functional, for example, multus and sriov-cni is disabled during bootstrap, and some of the container images still don’t have arm64 version to run.
