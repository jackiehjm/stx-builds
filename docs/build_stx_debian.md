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
# e.g.
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

#### 2.1.1 stx-init-env failed

* Example failure

```
[kubelet-check] Initial timeout of 40s passed.

Unfortunately, an error has occurred:
        timed out waiting for the condition

This error is likely caused by:
        - The kubelet is not running
        - The kubelet is unhealthy due to a misconfiguration of the node in some way (required cgroups disabled)

If you are on a systemd-powered system, you can try to troubleshoot the error with the following commands:
        - 'systemctl status kubelet'
        - 'journalctl -xeu kubelet'

Additionally, a control plane component may have crashed or exited when started by the container runtime.
To troubleshoot, list all containers using your preferred container runtimes CLI.
Here is one example how you may list all running Kubernetes containers by using crictl:
        - 'crictl --runtime-endpoint unix:///var/run/cri-dockerd.sock ps -a | grep kube | grep -v pause'
        Once you have found the failing container, you can inspect its logs with:
        - 'crictl --runtime-endpoint unix:///var/run/cri-dockerd.sock logs CONTAINERID'

stderr:
W0317 09:27:45.307806    1384 initconfiguration.go:119] Usage of CRI endpoints without URL scheme is deprecated and can cause kubelet errors in the future. Automatically prepending scheme "unix" to the "criSocket" with value "/var/run/cri-dockerd.sock". Please update your configuration!
        [WARNING Swap]: swap is enabled; production deployments should disable swap unless testing the NodeSwap feature gate of the kubelet
        [WARNING SystemVerification]: failed to parse kernel config: unable to load kernel module: "configs", output: "modprobe: FATAL: Module configs not found in directory /lib/modules/5.10.0-21-amd64\n", err: exit status 1
        [WARNING Service-Kubelet]: kubelet service is not enabled, please run 'systemctl enable kubelet.service'
error execution phase wait-control-plane: couldn't initialize a Kubernetes cluster
To see the stack trace of this error execute with --v=5 or higher
```

* Workaround: set the proxy before running stx-init-env

```
# e.g.
export http_proxy=http://147.11.252.42:9090
export https_proxy=http://147.11.252.42:9090
export no_proxy=localhost,127.0.0.1,10.96.0.0/12,192.168.0.0/16

# Then re-run the stx-init-env script
./stx-init-env
```

#### 2.1.2 Downloader failed

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

#### 2.1.3 Build-image failed because some package is downloaded incorrectly

* Example failure: libisl23_0.23-1_amd64.deb

```
# in <work_space_dir>/localdisk/log/log.appsdk
appsdk - DEBUG: dpkg-deb (subprocess): cannot copy archive member from '/tmp/apt-dpkg-install-1qCGdx/0345-libisl23_0.23-1_amd64.deb' to decompressor pipe: unexpected end of file or stream
appsdk - DEBUG: dpkg-deb (subprocess): decompressing archive '/tmp/apt-dpkg-install-1qCGdx/0345-libisl23_0.23-1_amd64.deb' (size=118240) member 'data.tar': lzma error: unexpected end of input
appsdk - DEBUG: dpkg-deb: error: <decompress> subprocess returned error exit status 2
appsdk - DEBUG: dpkg: error processing archive /tmp/apt-dpkg-install-1qCGdx/0345-libisl23_0.23-1_amd64.deb (--unpack):
appsdk - DEBUG:  cannot copy extracted data for './usr/lib/x86_64-linux-gnu/libisl.so.23.0.0' to '/usr/lib/x86_64-linux-gnu/libisl.so.23.0.0.dpkg-new': unexpected end of file or stream
```

* Workaround: 
  * manually download the package again as described in workaround 2 in 2.1.1
  * upload the package to pkg repo

  ```
  # in the stx-builder pod
  repo_manage.py delete_pkg -p libisl23_0.23-1_amd64 --repository deb-local-binary --package_type binary
  repo_manage.py upload_pkg -p /import/mirrors/starlingx/binaries/libisl23_0.23-1_amd64.deb --repository deb-local-binary
  ```

  * then re-run build-image


#### 2.1.4 Build-image failed because of upstream LAT is in dev [ONLY FOR WRCP 22.12]

* Example failure

```
appsdk - INFO: Create Debian Miniboot Initramfs: Succeeded(took 254 seconds)
appsdk - INFO: Sign Initramfs And Mini_initramfs: Started
appsdk - DEBUG: Running . None
appsdk - DEBUG: rc 2
appsdk - ERROR: Executing . None failed
2023-03-17 08:24:39,214 - build-image - INFO: Failed to build image, check the log /localdisk/log/log.appsdk
```

* Workaround 1: use an older version of LAT image
  * where to find the LAT image versions: https://hub.docker.com/r/starlingx/stx-lat-tool/tags

```
cd <work_space_dir>
source env.prj-stx-deb
cd src/stx-tools/
source import-stx

# delete minikube cluster
./stx-init-env --nuke

# recreate the cluster with older image
export STX_PREBUILT_BUILDER_IMAGE_TAG=master-debian-20230203T015600Z
./stx-init-env

# Enter the stx-builder pod
stx shell
# Then re-run build-image
build-image
```

* Workaround 2: rebuild the LAT image

```
cd <work_space_dir>
source env.prj-stx-deb
cd src/stx-tools/
source import-stx

# delete minikube cluster
./stx-init-env --nuke

# recreate the cluster with local rebuild image
./stx-init-env --rebuild=lat

# Enter the stx-builder pod
stx shell
# Then re-run build-image
build-image
```

### 2.2 Debug Tips

#### How to use kubectl command to debug containers

```
minikube -p minikube-<user>-upstream kubectl <subcommand and options>

# e.g.
minikube -p minikube-jhuang0-upstream kubectl get pods
```

#### How to debug with sbuild and chroot

```
# source the env
cd <work_space_dir>
source env.prj-stx-deb
cd src/stx-tools/
source import-stx

# Enter the stx-pkgbuilder pod
stx shell --container pkgbuilder

# [In stx-pkgbuilder] Modify the sbuild.conf to keep the build env when a pkg failed
# reference: https://manpages.debian.org/testing/sbuild/sbuild.conf.5.en.html
sed -i 's/always/successful/' /etc/sbuild/sbuild.conf
# or
sed -i 's/always/never/' /etc/sbuild/sbuild.conf

# Get the chroot name from the build command for specific pkg:
grep 'Build command' $STX_BUILD_HOME/localdisk/pkgbuilder.log|grep <pkg_name>

# e.g. for crictl
jackie@gigabyte-3:~/stx-arm-build-2023/ws-stx-arm64-20230202$ grep 'Build command' $STX_BUILD_HOME/localdisk/pkgbuilder.log|grep crictl
2023-02-02 13:15:23,385 - DEBUG: Build command: sbuild -d bullseye -j6 -c chroot:bullseye-arm64-jackie-3 --extra-repository='deb [trusted=yes] http://prj-oran-stx-deb-stx-repomgr:80/deb-local-build-3 bullseye main' --build-dir /localdisk/loadbuild/jackie/prj-oran-stx-deb/std/crictl /localdisk/loadbuild/jackie/prj-oran-stx-deb/std/crictl/crictl_1.0-1.stx.3.dsc

# [In stx-pkgbuilder] Enter the sbuild shell to debug
sbuild-shell <CHROOT_NAME>
bash
cd /build/<pkg_build_dir>

# run any steps that previously failed
```

### 2.3 Tips from ENG

* [Debian Package Tips](https://confluence.wrs.com/display/CE/Debian+Transition#DebianTransition-DebianPackageMigrationExamples/Tips/Tricks)

## 3. Detail docs for Debian Build and Developments

* [StarlingX Debian Build Environment](https://wiki.openstack.org/wiki/StarlingX/DebianBuildEnvironment)
* [StarlingX Debian Build Structure](https://wiki.openstack.org/wiki/StarlingX/DebianBuildStructure)
* [WRCP Debian Builds](https://confluence.wrs.com/display/CE/WRCP+Debian+Builds)
* [WRCP Debian Package Porting Guide](https://confluence.wrs.com/display/CE/Debian+Package+Conversion+Guide)
