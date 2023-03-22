#!/bin/bash
#### cryoSPARC cluster submission script template for PBS
## Available variables:
## {{ run_cmd }}            - the complete command string to run the job
## {{ num_cpu }}            - the number of CPUs needed
## {{ num_gpu }}            - the number of GPUs needed. 
##                            Note: the code will use this many GPUs starting from dev id 0
##                                  the cluster scheduler or this script have the responsibility
##                                  of setting CUDA_VISIBLE_DEVICES so that the job code ends up
##                                  using the correct cluster-allocated GPUs.
## {{ ram_gb }}             - the amount of RAM needed in GB
## {{ job_dir_abs }}        - absolute path to the job directory
## {{ project_dir_abs }}    - absolute path to the project dir
## {{ job_log_path_abs }}   - absolute path to the log file for the job
## {{ worker_bin_path }}    - absolute path to the cryosparc worker command
## {{ run_args }}           - arguments to be passed to cryosparcw run
## {{ project_uid }}        - uid of the project
## {{ job_uid }}            - uid of the job
## {{ job_creator }}        - name of the user that created the job (may contain spaces)
## {{ cryosparc_username }} - cryosparc username of the user that created the job (usually an email)
##
## What follows is a simple PBS script:

#PBS -N cryosparc_{{ project_uid }}_{{ job_uid }}
#PBS -l nodes=1:ppn={{ num_gpu*9 }}:gpus={{ num_gpu }}:skylake
#PBS -l mem={{ (ram_gb*1000)|int }}mb
#PBS -l partition=gpu
#PBS -A __credit_account__
#PBS -o {{ job_dir_abs }}
#PBS -e {{ job_dir_abs }}
#PBS -l walltime=24:00:00

cd $PBS_O_WORKDIR
module use /apps/leuven/${VSC_ARCH_LOCAL}/2021a/modules/all
module load CUDA/11.3.1

available_devs=""
for devidx in $(seq 0 3);
do
    if [[ -z $(nvidia-smi -i $devidx --query-compute-apps=pid --format=csv,noheader) ]] ; then
        if [[ -z "$available_devs" ]] ; then
            available_devs=$devidx
        else
            available_devs=$available_devs,$devidx
        fi
    fi
done
export CUDA_VISIBLE_DEVICES=$available_devs

export CRYOSPARC_SSD_PATH="${VSC_SCRATCH_NODE}"

{{ run_cmd }}
