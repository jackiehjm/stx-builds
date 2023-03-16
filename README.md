# StarlingX Builds

[TOC]

This aims to make the StarlingX builds and development more easier.

## 1. StarlingX Debian Builds

### 1.1 Quick start with wrapper script build_stx_debian.sh

#### 1.1.1 Install required packages

NOTE:
  * The build system requires a Linux system with Docker and python 3.x installed.
  * pek-sebuild3 and yow-wrcp-lx can be used directly.

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

#### 1.1.2 Use the script to build

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

### 2.2 Detail docs for Debian Build and Developments

For details docs, please refer to [build_stx_debian](./docs/build_stx_debian.md)

## 2. StarlingX CentOS builds

TODO

## 3. StarlingX Yocto builds

TODO



