#!/bin/bash

source set_environment.sh

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

# Install worker
if [ ! -d ${SPARCDIR}/cryosparc_worker ]; then
    echo "Installation files not found! Exiting"
    exit
fi
cd ${SPARCDIR}/cryosparc_worker
module use /apps/leuven/${VSC_ARCH_LOCAL}/2021a/modules/all
module load CUDA/11.3.1
./install.sh --license ${LICENSE_ID} --cudapath ${CUDA_ROOT}
