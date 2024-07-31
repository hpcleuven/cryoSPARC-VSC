#!/bin/bash -l

#SBATCH --job-name=install_cryosparc_worker
#SBATCH --nodes=1
#SBATCH --ntasks=9
#SBATCH --gpus-per-node=1
#SBATCH --partition=gpu_p100
#SBATCH --cluster=genius
#SBATCH --time=01:00:00
#SBATCH --account=<YOUR_CREDIT_ACCOUNT>

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
target=${SPARCDIR}/${VSC_OS_LOCAL}_${VSC_ARCH_LOCAL}${VSC_ARCH_SUFFIX}
mkdir -p ${target}
tar -xf cryosparc_worker.tar.gz -C ${target}

# Install worker
if [ ! -d ${target} ]; then
    echo "Installation files not found! Exiting"
    exit
fi
cd ${target}/cryosparc_worker

if [ $VSC_INSTITUTE_CLUSTER == "dodrio" ]
then
    module load CUDA/11.7.0
else
    module load CUDA/11.3.1
fi

# Versions of CryoSPARC prior to v4.4.0 require --cudapath ${CUDA_ROOT},
# in newer versions this option no longer exists
./install.sh --license ${LICENSE_ID} # --cudapath ${CUDA_ROOT}

# In some cases, the shebang of the conda executable is not set correctly.
# I am not sure why this happens, but replacing it seems enough to solve the issue.
cp deps/anaconda/bin/conda deps/anaconda/bin/conda.backup
sed -i "s|/usr/bin/env python|${PWD}/deps/anaconda/bin/python|" deps/anaconda/bin/conda
