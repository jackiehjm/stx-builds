#!/bin/sh
#
# Copyright (C) 2022 Wind River Systems, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Ensure we fail the job if any steps fail.
set -e -o pipefail

#########################################################################
# Variables
#########################################################################
WORKSPACE=""
SCRIPTS_NAME=$(basename $0)

LOCAL_BIN="/usr/local/bin"
USE_SUDO="sudo"

#########################################################################
# Common Functions
#########################################################################

help_info () {
cat << ENDHELP
Usage:
${SCRIPTS_NAME} [-w WORKSPACE_DIR] [-h]
where:
    -w WORKSPACE_DIR is the path for the builds
    -l LOCAL_BIN is the path for local bin, default is /usr/local/bin
    -h this help info
examples:
$0
$0 -w workspace_1234
ENDHELP
}

echo_info () {
    echo "INFO: $1"
}

while getopts "w:l:h" OPTION; do
    case ${OPTION} in
        w)
            WORKSPACE=`readlink -f ${OPTARG}`
            ;;
        l)
            LOCAL_BIN=`readlink -f ${OPTARG}`
	    ;;
        h)
            help_info
            exit
            ;;
    esac
done

if [ -d ${LOCAL_BIN} ]; then
    touch ${LOCAL_BIN}/test && USE_SUDO="" && rm ${LOCAL_BIN}/test
else
    echo "ERROR: ${LOCAL_BIN} doesn't exists!!"
    exit
fi

#########################################################################
# Main process
#########################################################################
echo_info "Install minikube"
mkdir -p ${WORKSPACE}/dl-tools
cd ${WORKSPACE}/dl-tools

if [ ! -f ${LOCAL_BIN}/minikube ]; then
    curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    ${SUDO} install minikube-linux-amd64 ${LOCAL_BIN}/minikube
fi
minikube version

echo_info "Install helm"
if [ ! -f ${LOCAL_BIN}/helm ]; then
    curl -LO https://get.helm.sh/helm-v3.6.2-linux-amd64.tar.gz
    tar xvf helm-v3.6.2-linux-amd64.tar.gz
    ${SUDO} mv linux-amd64/helm ${LOCAL_BIN}/
fi

echo_info "Install repo tool"
if [ ! -f ${LOCAL_BIN}/repo ]; then
    ${SUDO} wget https://storage.googleapis.com/git-repo-downloads/repo -O ${LOCAL_BIN}/repo
    ${SUDO} chmod a+x ${LOCAL_BIN}/repo
fi
