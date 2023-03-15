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

## 2. Build Tips

TODO

## 3. Detail docs for Debian Build and Developments

* [StarlingX Debian Build Environment](https://wiki.openstack.org/wiki/StarlingX/DebianBuildEnvironment)
* [StarlingX Debian Build Structure](https://wiki.openstack.org/wiki/StarlingX/DebianBuildStructure)
* [WRCP Debian Builds](https://confluence.wrs.com/display/CE/WRCP+Debian+Builds)
* 
