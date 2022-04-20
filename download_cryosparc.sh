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
curl -L https://get.cryosparc.com/download/worker-latest/$LICENSE_ID -o cryosparc_worker.tar.gz
tar -xf cryosparc_master.tar.gz cryosparc_master
tar -xf cryosparc_worker.tar.gz cryosparc_worker
