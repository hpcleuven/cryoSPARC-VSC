# cryoSPARC on the VSC clusters

This guide provides pointers to install cryoSPARC. It is based on the
instructions provided at
https://guide.cryosparc.com/setup-configuration-and-management/how-to-download-install-and-configure/downloading-and-installing-cryosparc
customised for the VSC cluster (specifically the KU Leuven Tier-2 HPC). The
proposed solution is based on a user installing cryoSPARC master in his
personal directory and running the services on a login node.

## Prerequisites

It is assumed you have an active VSC account. Because the interaction with
cryoSPARC happens through a webserver (that will run on the login node), you
need a graphical connection. It is highly recommended to use NX for this:
https://docs.vscentrum.be/en/latest/access/nx_start_guide.html In order to run
jobs you also need a credit account. Finally you need a cryoSPARC license
(which can be obtained for free for academic usage).

The second requirement is that you can access the files of this repository on
the cluster. The easiest way is by setting up authentication with Github using
an ssh key as explained on
https://docs.github.com/en/authentication/connecting-to-github-with-ssh
If this is set up correctly, it should be sufficient to run:

```git clone git@github.com:hpcleuven/cryoSPARC-VSC.git```

When the files in the repository are updated, you can synchronize your local
version by running

```git pull```

in the directory where you cloned the repository.

## Installing cryoSPARC

First you need to edit the file `set_environment.sh` and specify your
cryoSPARC license id and your credit account on the VSC. Optionally,
you can adapt the installation directory but somewhere in ${VSC_DATA} is
probably the best option. You can also set the directory where cryoSPARC will
do SSD particle caching (see
https://guide.cryosparc.com/setup-configuration-and-management/software-system-guides/tutorial-ssd-particle-caching-in-cryosparc).

The installation of the cryoSPARC master can be done by running:

```bash install_cryosparc_master.sh```

This can take some time. During the actual installation, you will be prompted
to indicate some settings which should be self-explanatory.

Next, you need to install the cryoSPARC worker. Different types of GPUs are
available and it is recommended to install the worker separately for different
types of GPUs. Additionally it is recommended to do the installation on a
compute node that has the GPU in question. Therefore the worker installation
will be done inside a job that is submitted to a compute node. A template job
is provided in `install_cryosparc_worker.slurm`. You will need to modify this
template, for instance for the P100 GPUs on the genius cluster the header looks
like this:

```
#SBATCH --job-name=install_cryosparc_worker
#SBATCH --nodes=1
#SBATCH --ntasks=9
#SBATCH --gpus-per-node=1
#SBATCH --partition=gpu_p100
#SBATCH --cluster=genius
#SBATCH --time=01:00:00
#SBATCH --account=lkd-group
```

which you can submit with `sbatch install_cryosparc_worker.slurm`. If
everything goes well, the cryoSPARC worker will be installed in
`${SPARCDIR}/centos7_skylake/cryosparc_worker`. Check the corresponding job
output file in case something goes wrong.

> **_NOTE:_** The value of `--account` should be a credit account to which
you have access. Execute `sam-balance` on the cluster to see to which accounts
you have access.

On the genius cluster there are also two nodes with V100 GPUs, for which the
header looks like:

```
#SBATCH --job-name=install_cryosparc_worker
#SBATCH --nodes=1
#SBATCH --ntasks=4
#SBATCH --gpus-per-node=1
#SBATCH --partition=gpu_v100
#SBATCH --cluster=genius
```

On the wICE cluster, A100 GPUs are available. To install the cryoSPARC worker
there, use the following header in the job script:

```
#SBATCH --job-name=install_cryosparc_worker
#SBATCH --nodes=1
#SBATCH --ntasks=18
#SBATCH --gpus-per-node=1
#SBATCH --partition=gpu
#SBATCH --cluster=wice
```

> **_NOTE:_** It is not mandatory to have the worker installed for all types
of GPUs. It is perfectly fine to do this only for one specific type of GPU,
but in that case you will be limited to running jobs only for that type of GPU.
you have access.

## Starting and running the webserver

Now the cryoSPARC master process can be started by running

```cryosparcm start```

in a terminal inside NX. If all goes well, this should print an address at
which you can access the cryoSPARC web services. It looks as follows:

```http://tier2-p-login-3.genius.hpc.kuleuven.be:37160```

This is the address you should visit in the NX web browser.

In case of problems, you can have a look at:
https://guide.cryosparc.com/setup-configuration-and-management/management-and-monitoring/cryosparcm

### Adding a cryoSPARC user

Before you can actually use cryoSPARC, you need to create a cryoSPARC user
for yourself. You can adapt the settings to your liking:

```
cryosparcm createuser --email "john.doe@kuleuven.be" \
                      --password "abcdefg" \
                      --username "johndoe" \
                      --firstname "John" \
                      --lastname "Doe"
```

### Adding clusters to run jobs 

To allow cryoSPARC to submit jobs to the batch scheduler, you need to add
clusters. This is automated with the `connect_clusters.sh` script:

```bash connect_clusters.sh```

Currently a `genius-p100-debug` and `genius-p100` cluster are configured which
you can choose from later on when interacting with the cryoSPARC webserver.
The first one submits jobs to the debug queue; these are likely to spend
less time in the queue, but are limited in walltime to 30 minutes.

### Using cryoSPARC

Now you can visit the address obtained after starting the cryoSPARC master
in a browser and login with the credentials specified when creating a cryoSPARC
user. From there you can follow the tutorial provided here:
https://guide.cryosparc.com/processing-data/cryo-em-data-processing-in-cryosparc-introductory-tutorial
Remember that large files should be stored in your $VSC_SCRATCH directory.
