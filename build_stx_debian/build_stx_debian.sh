#!/bin/bash
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# Ensure we fail the job if any steps fail.
set -e -o pipefail

#########################################################################
# Variables
#########################################################################

SRC_SCRIPTS_BRANCH="master"

SRC_SCRIPTS_URL="https://gitlab.aws-eu-north-1.devstar.cloud/jhuang0/stx-builds.git"

SCRIPTS_DIR=$(dirname $(readlink -f $0))
SCRIPTS_NAME=$(basename $0)
TIMESTAMP=`date +"%Y%m%d_%H%M%S"`

STX_PARALLEL="2"

STX_SRC_BRANCH_SUPPORTED="\
    master \
    r/stx.8.0 \
    WRCP_22.12 \
"
STX_SRC_BRANCH="master"
STX_MANIFEST_URL="https://opendev.org/starlingx/manifest"
STX_MANIFEST_URL_WRCP="ssh://git@vxgit.wrs.com:7999/cgcs/github.com.stx-staging.stx-manifest.git"

#########################################################################
# Common Functions
#########################################################################

help_info () {
cat << ENDHELP
Usage:
${SCRIPTS_NAME} [-w WORKSPACE_DIR] [-p PARALLEL_BUILD] [-b STX_SRC_BRANCH] [-h]
where:
    -w WORKSPACE_DIR is the path for the project
    -p PARALLEL_BUILD is the num of paralle build, default is 2
    -b STX_SRC_BRANCH is the branch for stx repos, default is master
    -h this help info
examples:
$0
$0 -w workspace_1234
ENDHELP
}

echo_step_start() {
    [ -n "$1" ] && msg_step=$1
    echo "#########################################################################################"
    echo "## ${SCRIPTS_NAME} - STEP START: ${msg_step}"
    echo "#########################################################################################"
}

echo_step_end() {
    [ -n "$1" ] && msg_step=$1
    echo "#########################################################################################"
    echo "## ${SCRIPTS_NAME} - STEP END: ${msg_step}"
    echo "#########################################################################################"
    echo
}

echo_info () {
    echo "INFO: $1"
}

echo_error () {
    echo "ERROR: $1"
}

run_cmd () {
    echo
    echo_info "$1"
    echo "CMD: ${RUN_CMD}"
    ${RUN_CMD}
}

check_valid_branch () {
    branch="$1"
    for b in ${STX_SRC_BRANCH_SUPPORTED}; do
        if [ "${branch}" == "${b}" ]; then
            BRANCH_VALID="${branch}"
            break
        fi
    done
    if [ -z "${BRANCH_VALID}" ]; then
        echo_error "${branch} is not a supported BRANCH, the supported BRANCHs are: ${STX_SRC_BRANCH_SUPPORTED}"
        exit 1
    else
        STX_SRC_BRANCH=${BRANCH_VALID}
    fi
}


#########################################################################
# Parse cmd options
#########################################################################


while getopts "w:p:b:h" OPTION; do
    case ${OPTION} in
        w)
            WORKSPACE=`readlink -f ${OPTARG}`
            ;;
        p)
            STX_PARALLEL="${OPTARG}"
            ;;
        b)
            check_valid_branch ${OPTARG}
            ;;
        h)
            help_info
            exit
            ;;
    esac
done

if [ -z ${WORKSPACE} ]; then
    echo_info "No workspace specified, a directory 'workspace' will be created in current directory as the workspace"
    WORKSPACE=`readlink -f workspace`
fi

if [[ ${STX_SRC_BRANCH} =~ "WRCP" ]]; then
    STX_MANIFEST_URL=${STX_MANIFEST_URL_WRCP}
fi

#########################################################################
# Functions for each step
#########################################################################

# "_" can't be used in project name
PRJ_NAME=prj-stx-deb

STX_LOCAL_DIR=${WORKSPACE}/localdisk
STX_LOCAL_SRC_DIR=${STX_LOCAL_DIR}/designer/${USER}/${PRJ_NAME}
STX_LOCAL_PRJ_DIR=${STX_LOCAL_DIR}/loadbuild/${USER}/${PRJ_NAME}
STX_SRC_DIR=${WORKSPACE}/src
STX_PRJ_DIR=${WORKSPACE}/${PRJ_NAME}
STX_PRJ_OUTPUT=${WORKSPACE}/prj_output
STX_MIRROR_DIR=${WORKSPACE}/mirrors
STX_APTLY_DIR=${WORKSPACE}/aptly
STX_MINIKUBE_HOME=${WORKSPACE}/minikube_home

SRC_SCRIPTS_DIR=${STX_SRC_DIR}/stx-builds
SRC_META_PATCHES=${SRC_SCRIPTS_DIR}/build_stx_debian/meta-patches

ISO_STX_DEB=stx-image-debian-all-x86-64.iso

prepare_workspace () {
    msg_step="Create workspace for the Debian build"
    echo_step_start

    mkdir -p ${STX_LOCAL_SRC_DIR} ${STX_LOCAL_PRJ_DIR} ${STX_MIRROR_DIR} \
        ${STX_APTLY_DIR} ${STX_PRJ_OUTPUT} ${STX_MINIKUBE_HOME}
    rm -f ${STX_SRC_DIR} ${STX_PRJ_DIR}
    ln -sf $(realpath --relative-to=${WORKSPACE} ${STX_LOCAL_SRC_DIR}) ${STX_SRC_DIR}
    ln -sf $(realpath --relative-to=${WORKSPACE} ${STX_LOCAL_PRJ_DIR}) ${STX_PRJ_DIR}

    echo_info "The following directories are created in your workspace(${WORKSPACE}):"
    echo_info "For all source repos: ${STX_SRC_DIR}"
    echo_info "For StarlingX deb pkgs mirror: ${STX_MIRROR_DIR}"
    echo_info "For StarlingX build project: ${STX_PRJ_DIR}"

    echo_step_end
}

create_env () {
    msg_step="Create env file for the Debian build"
    echo_step_start

    ENV_FILENAME=env.${PRJ_NAME}

    cat <<EOF > ${WORKSPACE}/${ENV_FILENAME}

export STX_BUILD_HOME=${WORKSPACE}
export PROJECT=${PRJ_NAME}
export STX_MIRROR_DIR=${STX_MIRROR_DIR}
export STX_REPO_ROOT=${STX_SRC_DIR}
#export STX_REPO_ROOT_SUBDIR="localdisk/designer/${USER}/${PRJ_NAME}"

export USER_NAME=${USER}
export USER_EMAIL=${USER}@windriver.com

# MINIKUBE
export STX_PLATFORM="minikube"
export STX_MINIKUBENAME="minikube-${USER}"
export MINIKUBE_HOME=${STX_MINIKUBE_HOME}

# Manifest/Repo Options:
export STX_MANIFEST_URL="${STX_MANIFEST_URL}"
export STX_MANIFEST_BRANCH="${STX_SRC_BRANCH}"
export STX_MANIFEST="default.xml"

EOF

    echo_info "Env file created at ${WORKSPACE}/$ENV_FILENAME"
    cat ${WORKSPACE}/$ENV_FILENAME

    source ${WORKSPACE}/${ENV_FILENAME}

    git config --global user.email "${USER_EMAIL}"
    git config --global user.name "${USER_NAME}"
    git config --global color.ui false

    echo_step_end
}

repo_init_sync () {
    msg_step="Init the repo and sync"
    echo_step_start

    # Avoid the colorization prompt
    git config --global color.ui false

    if [ -d ${STX_REPO_ROOT}/.repo ]; then
        echo_info "the src repos already exists, skipping"
    else
        cd ${STX_REPO_ROOT}

        RUN_CMD="repo init -u ${STX_MANIFEST_URL} -b ${STX_SRC_BRANCH} -m ${STX_MANIFEST}"
        run_cmd "Init the repo from manifest"

        RUN_CMD="repo sync --force-sync"
        run_cmd "repo sync"

        touch .repo-init-done
    fi

    echo_step_end
}

clone_update_repo () {
    REPO_BRANCH=$1
    REPO_URL=$2
    REPO_NAME=$3
    REPO_COMMIT=$4

    if [ -d ${REPO_NAME}/.git ]; then
        if [ "${SKIP_UPDATE}" == "Yes" ]; then
            echo_info "The repo ${REPO_NAME} exists, skip updating for the branch ${REPO_BRANCH}"
        else
            echo_info "The repo ${REPO_NAME} exists, updating for the branch ${REPO_BRANCH}"
            cd ${REPO_NAME}
            git checkout ${REPO_BRANCH}
            git pull
            cd -
        fi
    else
        RUN_CMD="git clone --branch ${REPO_BRANCH} ${REPO_URL} ${REPO_NAME}"
        run_cmd "Cloning the source of repo '${REPO_NAME}':"

        if [ -n "${REPO_COMMIT}" ]; then
            cd ${REPO_NAME}
            RUN_CMD="git checkout -b ${REPO_BRANCH}-${REPO_COMMIT} ${REPO_COMMIT}"
            run_cmd "Checkout the repo ${REPO_NAME} to specific commit: ${REPO_COMMIT}"
            cd -
        fi
    fi
}


prepare_src () {
    msg_step="Get the source code repos"
    echo_step_start

    # Clone the stx-builds repo if it's not already cloned
    # Check if the script is inside the repo
    if cd ${SCRIPTS_DIR} && git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        CLONED_SCRIPTS_REPO=`git rev-parse --show-toplevel`
        echo_info "Use the cloned stx-builds repo: ${CLONED_SCRIPTS_REPO}"
        cd ${STX_SRC_DIR}
        ln -sf ${CLONED_SCRIPTS_REPO}
    else
        echo_info "Cloning stx-builds repo:"
        cd ${STX_SRC_DIR}
        clone_update_repo ${SRC_SCRIPTS_BRANCH} ${SRC_SCRIPTS_URL}
    fi

    repo_init_sync
    patch_src

    echo_step_end
}


patch_src () {
    echo_step_start "Patching source codes for stx project"

    STX_BUILDER="${STX_REPO_ROOT}/stx-tools/stx/lib/stx/stx_build.py"
    echo_info "Patching for the ${STX_BUILDER}"
    grep -q "\-\-parallel" ${STX_BUILDER} \
        || sed -i "s/\(build-pkgs -a \)/\1 --parallel ${STX_PARALLEL} /" \
        ${STX_BUILDER}

    # Apply meta patches
    if [ -d ${SRC_META_PATCHES} ]; then
        cd ${SRC_META_PATCHES}
        src_dirs=$(find . -type f -printf "%h\n"|uniq)
        for d in ${src_dirs}; do
            cd ${STX_REPO_ROOT}/${d}

            # backup current branch
            local_branch=$(git rev-parse --abbrev-ref HEAD)
            if [ "${local_branch}" = "HEAD" ]; then
                git checkout ${STX_SRC_BRANCH}
                local_branch=$(git rev-parse --abbrev-ref HEAD)
            fi
            git branch -m "${local_branch}_${TIMESTAMP}"
            git checkout ${STX_SRC_BRANCH}

            for p in $(ls -1 ${SRC_META_PATCHES}/${d}); do
                echo_info "Apllying patch: ${SRC_META_PATCHES}/${d}/${p}"
                git am ${SRC_META_PATCHES}/${d}/${p}
            done
        done
    fi

    echo_step_end
}

init_stx_tool () {
    echo_step_start "Init stx tool"

    cd ${STX_REPO_ROOT}
    cd stx-tools
    cp stx.conf.sample stx.conf
    source import-stx

    # Update stx config
    # Align the builder container to use your user/UID
    stx config --add builder.myuname $(id -un)
    stx config --add builder.uid $(id -u)

    # Embedded in ~/localrc of the build container
    stx config --add project.gituser ${USER_NAME}
    stx config --add project.gitemail ${USER_EMAIL}

    # This will be included in the name of your build container and the basename for $STX_REPO_ROOT
    stx config --add project.name ${PRJ_NAME}

    #stx config --add project.proxy true
    #stx config --add project.proxyserver 147.11.252.42
    #stx config --add project.proxyport 9090

    stx config --show

    echo_step_end
}

build_image () {
    echo_step_start "Build Debian images"

    cd ${STX_REPO_ROOT}/stx-tools
    RUN_CMD="./stx-init-env"
    run_cmd "Run stx-init-env script"

    stx control status

    # wait for all the pods running
    sleep 600
    stx control status

    RUN_CMD="stx build prepare"
    run_cmd "Build prepare"

    RUN_CMD="stx build download"
    run_cmd "Download packges"

    RUN_CMD="stx repomgr list"
    run_cmd "repomgr list"

    RUN_CMD="stx build world"
    run_cmd "Build-pkgs"

    RUN_CMD="stx build image"
    run_cmd "Build ISO image"

    cp -f ${STX_LOCAL_DIR}/deploy/starlingx-intel-x86-64-cd.iso ${STX_PRJ_OUTPUT}/${ISO_STX_DEB}

    echo_step_end

    echo_info "Build succeeded, you can get the image in ${STX_PRJ_OUTPUT}/${ISO_STX_DEB}"
}

#########################################################################
# Main process
#########################################################################

prepare_workspace
create_env
prepare_src
init_stx_tool
build_image
