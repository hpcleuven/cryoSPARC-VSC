#!/bin/bash

#SBATCH --job-name=install_cryosparc_worker
#SBATCH --nodes=1
#SBATCH --ntasks=18
#SBATCH --gpus-per-node=2
#SBATCH --time=01:00:00
#SBATCH --account=<YOUR_CREDIT_ACCOUNT>
#SBATCH --partition=gpu
#SBATCH --cluster=wice

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
curl -L https://get.cryosparc.com/download/worker-latest/$LICENSE_ID -o cryosparc_worker.tar.gz
tar -xf cryosparc_worker.tar.gz cryosparc_worker_${VSC_INSTITUTE_CLUSTER}

# Install worker
if [ ! -d ${SPARCDIR}/cryosparc_worker_${VSC_INSTITUTE_CLUSTER} ]; then
    echo "Installation files not found! Exiting"
    exit
fi
cd ${SPARCDIR}/cryosparc_worker_${VSC_INSTITUTE_CLUSTER}
module use /apps/leuven/${VSC_ARCH_LOCAL}/2021a/modules/all
module load CUDA/11.3.1
./install.sh --license ${LICENSE_ID} --cudapath ${CUDA_ROOT}
