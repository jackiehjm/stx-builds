# StarlingX Debian Builds

[TOC]

This is for StarlingX Debian builds and developments.

## 1. Quick start with wrapper script build_stx_debian.sh

### 1.1 Install required packages

NOTE:
   * The build system requires a Linux system with Docker and python 3.x installed.
   * pek-sebuild3 and yow-wrcp-lx can be used directly, please skip this step.

1. Install Docker Engine:
   * ref: https://docs.docker.com/engine/install/

2. Add user to docker group

```
sudo usermod -aG docker $(id -un) && newgrp docker
```

3. Install helm, minikube and repo

```
git clone https://gitlab.aws-eu-north-1.devstar.cloud/jhuang0/stx-builds.git
./stx-builds/build_stx_debian/build_stx_host_prepare.sh
```

### 1.2 Use the script to build

* [optional] set proxy before running the script

```
export http_proxy=http://147.11.252.42:9090
export https_proxy=http://147.11.252.42:9090
export no_proxy=localhost,127.0.0.1,10.96.0.0/12,192.168.59.0/24,192.168.49.0/24,192.168.39.0/24,192.168.67.0/24,192.168.49.2
```

* Get and run the script

```
git clone https://gitlab.aws-eu-north-1.devstar.cloud/jhuang0/stx-builds.git

./stx-builds/build_stx_debian/build_stx_debian.sh -w <work_space_dir> -b <stx_branch> -p <parralel_build_num>

# stx_branch is the StarlingX/WRCP repo branch to build, default is "master"
# supported branches are:
# - master
# - r/stx.8.0
# - WRCP_22.12
# e.g.
./stx-builds/build_stx_debian/build_stx_debian.sh -w ws-stx-master -p 8
./stx-builds/build_stx_debian/build_stx_debian.sh -w ws-wrcp22.12 -b WRCP_22.12 -p 10
```

* How to re-run each steps if the above script fail

```
# source the env and enter the stx-builder pod
cd <work_space_dir>
source env.prj-stx-deb
cd src/stx-tools/
source import-stx
stx shell

# Run the downloader
downloader -b -s

# Build a specifi package
build-pkgs -p <pkg_name>

# Build all packages
build-pkgs -a --parallel <num_parallel_tasks>

# Build image
build-image
```

## 2. Build Tips

### 2.1 Known issues and Workarounds

#### 2.1.1 Downloader failed

You may encounter the following downloader failure if there is unexpected network issue:

```
# e.g.
2023-03-13 17:46:36,947 - downloader - ERROR: Binary downloader failed
2023-03-13 17:46:36,947 - downloader - ERROR: Packages failed to download:
2023-03-13 17:46:36,947 - downloader - ERROR: systemtap-sdt-dev_4.4-2
```

* Workaround 1: you can try to re-run the downloader

```
# source the env and enter the stx-builder pod
cd <work_space_dir>
source env.prj-stx-deb
cd src/stx-tools/
source import-stx
stx shell

# re-run the downloader
downloader -b -s
```

* Workaround 2: try to find the failed packages and download manually

```
# Find the failed packages on yow-wrcp-lx:/import/mirrors/debian
# e.g.
jhuang0@yow-wrcp-lx /import/mirrors/debian $ find . -name systemtap-sdt-dev_4.4-2*
./debian/ftp.ca.debian.org/debian/pool/main/s/systemtap/systemtap-sdt-dev_4.4-2_amd64.deb

# Then copy the found package to your <work_space_dir>/mirrors
# e.g.
scp ./debian/ftp.ca.debian.org/debian/pool/main/s/systemtap/systemtap-sdt-dev_4.4-2_amd64.deb <your_build_host_ip>:<work_space_dir>/mirrors/starlingx/binaries
```

After downloading all failed packages manually, re-run the downloader as described in Workaround 1.


## 3. Detail docs for Debian Build and Developments

* [StarlingX Debian Build Environment](https://wiki.openstack.org/wiki/StarlingX/DebianBuildEnvironment)
* [StarlingX Debian Build Structure](https://wiki.openstack.org/wiki/StarlingX/DebianBuildStructure)
* [WRCP Debian Builds](https://confluence.wrs.com/display/CE/WRCP+Debian+Builds)
* [WRCP Debian Package Porting Guide](https://confluence.wrs.com/display/CE/Debian+Package+Conversion+Guide)
