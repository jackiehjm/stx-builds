#!/bin/sh
#
# Copyright (c) 2023 Wind River Systems, Inc.
#
# The right to copy, distribute, modify, or otherwise make use
# of this software may be licensed only pursuant to the terms
# of an applicable Wind River license agreement.
#

# Use on the builder container of StarlingX Debian:
#   git config --global user.name 'Example';
#   git config --global user.email Example_Email@xxx.com;
#   <The full path of this script>/build-sdk.sh [Don't use relative path]
#
# Pay attention: please update below [downloading sites] to the nearest
# sites to your building server, or else it will affect the code
# downloading time greatly and maybe cause failures.

# ===Set code downloading sites===
# Build on ala server
WRL_GIT_PATH=git://lxgit.wrs.com/wrlinux-x
URL_META_LAT=https://github.com/Wind-River/meta-lat.git
LAT_STX_BRANCH=STARLINGX-9.0
# Build on pek server
# WRL_GIT_PATH=git://pek-git.wrs.com/wrlinux-x
# URL_META_LAT=git://pek-git.wrs.com/layers/meta-lat.git
# LAT_STX_BRANCH=upstream-STARLINGX-9.0

# ===Set LAT sdk build path===
LAT_BUILD_PATH=/localdisk/LAT_BUILD/

WRL_VERSION=WRLINUX_10_22_LTS_RCPL0003
WRLINUX_PATH=wrlinux-1022

# Extra fix:
#   layer:  meta-openembedded
#   commit: 19c6b9a cdrkit: add new option -eltorito-platform for genimageiso
PATCH_FIX1=19c6b9a32432e56ac03373193eb2e4b44a33547c

# Install tools needed on builder container.
sudo apt-get -y install diffstat gawk libc6-dev libgomp1 \
|| { echo "Fail to install build ENV!"; exit 1; }

# Check git config.
git config --get user.name \
|| { echo "Please git config user.name first!"; exit 1; }
git config --get user.email \
|| { echo "Please git config user.email first!"; exit 1; }

# Check the LAT build path.
if [ ! -d ${LAT_BUILD_PATH} ]; then
    echo "Create the non-existent build dir!"
    mkdir -p ${LAT_BUILD_PATH} || { echo "Invalid build dir!"; exit 1; }
fi
cd ${LAT_BUILD_PATH}

DATE=`date +%m%d%H`
mkdir lat_stx_${DATE} || { echo "Please clean the build dir first!"; exit 1; }
cd lat_stx_${DATE}
echo "LAT sdk build path: $(pwd)"

mkdir mirror
cd mirror
git clone --depth 1 --branch ${WRL_VERSION} ${WRL_GIT_PATH} ${WRLINUX_PATH} \
|| { echo "Fail to clone wrlinux-x from server!"; exit 1; }

./${WRLINUX_PATH}/setup.sh --all-layers --dl-layers --mirror --accept-eula=yes \
|| { echo "Fail to setup wrlinux mirror!"; exit 1; }
cd -

mkdir prj
cd prj
git clone --branch ${WRL_VERSION} ../mirror/${WRLINUX_PATH} ${WRLINUX_PATH} \
|| { echo "Fail to clone local wrlinux-x!"; exit 1; }

./${WRLINUX_PATH}/setup.sh --distro=wrlinux-graphics --machines=intel-x86-64 \
--templates feature/ostree feature/lat feature/docker feature/efi-secure-boot \
--layers meta-lat --dl-layers --accept-eula=yes \
|| { echo "Fail to setup local wrlinux!"; exit 1; }

cd layers
rm ./meta-lat -rf
counter=1
while [ ${counter} -le 5 ]; do
    git clone ${URL_META_LAT} && break;
    echo "Fail to clone meta-lat. Try again!"
    counter=$(( counter + 1 ))
done
cd meta-lat || { echo "Fail to clone newest meta-lat!"; exit 1; }

# Branch STARLINGX-9.0 maintains the meta-lat version for StarlingX Debian.
git checkout ${LAT_STX_BRANCH} \
|| { echo "Fail to checkout stx branch for meta-lat!"; exit 1; }

# We put all the commits for debugging meta-lat in ./meta-lat dir
# (in the same path with this script) with number sequence in their names.
if [ -d $(dirname $0)/meta-lat ]; then
    git am $(dirname $0)/meta-lat/*.patch \
    || { echo "Fail to apply debugging patches for meta-lat!"; exit 1; }
else
    echo "No debugging patches located at $(dirname $0)/meta-lat."
fi
cd ../../

# Other necessary fixes from newer version wrlinux layers than
# WRL_VERSION that we use as the base.
cd layers/meta-openembedded
git format-patch -1 ${PATCH_FIX1}
git am *.patch \
|| { echo "Fail to apply patches for meta-openembedded!"; exit 1; }
rm *.patch
cd ../../

. ./environment-setup-x86_64-wrlinuxsdk-linux
. ./oe-init-build-env
# Set a GPG_PATH which will be ignored by pseudo in case gpg failure
# occurs because of pseudo issue.
echo "GPG_PATH = '/tmp/lat/'" >> conf/local.conf

bitbake container-base -ccleansstate && bitbake container-base -cpopulate_sdk
