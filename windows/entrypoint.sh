#! /bin/bash

set -ex

BRANCH=$1
JOBS=$2
DEBUG=$3
REVISION=$4
ZIP_NAME="windows_agent_${REVISION}.zip"

URL_REPO=https://github.com/wazuh/wazuh/archive/${BRANCH}.zip

# Download the wazuh repository
wget -O wazuh.zip ${URL_REPO} && unzip wazuh.zip

# Compile the wazuh agent for Windows
FLAGS="-j ${JOBS}"

if [[ "${DEBUG}" = "yes" ]]; then
    FLAGS+="-d "
fi

make -C /wazuh-*/src deps TARGET=winagent ${FLAGS} EXTERNAL_SRC_ONLY=yes
make -C /wazuh-*/src TARGET=winagent ${FLAGS}


for library in ${rpm_build_dir}/BUILD/${package_name}/src/external/* ; do
    tar -zcf /shared/$(basename $library).tar.gz -C /wazuh-*/src/external $(basename $library) --owner=0 --group=0
done

rm -rf /wazuh-*/src/external

# Zip the compiled agent and move it to the shared folder
zip -r ${ZIP_NAME} wazuh-*
cp ${ZIP_NAME} /shared