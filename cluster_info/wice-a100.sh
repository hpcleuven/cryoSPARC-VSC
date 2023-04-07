#!/bin/bash -l
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
## What follows is a simple SLURM script:

#SBATCH --job-name=cryosparc_{{ project_uid }}_{{ job_uid }}
#SBATCH --nodes=1
#SBATCH --ntasks={{ num_gpu*18 }}
#SBATCH --gpus-per-node={{ num_gpu }}
#SBATCH --account=__credit_account__
#SBATCH --partition=gpu
#SBATCH --output={{ job_log_path_abs }}
#SBATCH --error={{ job_log_path_abs }}
#SBATCH --time=24:00:00

cd $SLURM_SUBMIT_DIR
module use /apps/leuven/icelake/2021a/modules/all
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

if [ -z ${CRYOSPARC_SSD_PATH+x} ]; then
    export CRYOSPARC_SSD_PATH=__ssd_path__
fi

echo "CUDA_VISIBLE_DEVICES=" $CUDA_VISIBLE_DEVICES
echo {{ run_cmd }}
{{ run_cmd }}
