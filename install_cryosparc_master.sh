#!/bin/bash

source set_environment.sh

# Check that SPARCDIR is provided where cryoSPARC will be installed
if [ -z ${SPARCDIR+x} ]
then
    echo "SPARCDIR not set, quitting"
    exit
fi

mkdir -p ${SPARCDIR}
cd ${SPARCDIR}

# Check that license is provided
if [ -z ${LICENSE_ID+x} ]
then
    echo "Provide a valid LICENSE_ID before downloading"
    exit
fi

# Download and extract tar files
curl -L https://get.cryosparc.com/download/master-latest/$LICENSE_ID -o cryosparc_master.tar.gz
mkdir cryosparc_master
tar -xf cryosparc_master.tar.gz -C cryosparc_master

# Install master
if [ ! -d ${SPARCDIR}/cryosparc_master ]; then
    echo "Installation files not found! Exiting"
    exit
fi
cd ${SPARCDIR}/cryosparc_master
user_id=$(whoami)
export port_number=${user_id: -4}0
export master_hostname=$(echo -e "$(hostname -f)" | tr -d '[:space:]')

./install.sh --license $LICENSE_ID \
             --hostname ${master_hostname} \
             --dbpath ${SPARCDIR}/db \
             --port ${port_number}
