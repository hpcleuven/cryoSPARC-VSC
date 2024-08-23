# cryoSPARC on the VSC clusters

This guide provides pointers to install cryoSPARC. It is based on the
[official cryoSPARC guide](https://guide.cryosparc.com/setup-configuration-and-management/how-to-download-install-and-configure/downloading-and-installing-cryosparc),
but has been customised for the VSC cluster. It has been tested on the KU
Leuven Tier-2 clusters and on the Hortense Tier-1 cluster. The proposed
solution is based on a user installing cryoSPARC master in their personal
directory with a single user in the cryoSPARC database. It is assumed that
computationally intensive work (which involves running `cryosparc_worker`)
is submitted to a scheduler as jobs on the cluster.

## Prerequisites

It is assumed you have an active VSC account. In order to run jobs you also need
a valid credit account.

Because the interaction with cryoSPARC happens through a webserver, you will
need to either have a graphical connection to the node where the webserver is
running, or set up port forwarding between your machine and the node where the
webserver runs (instructions for the latter case can be found at the end of this document).

- **KU Leuven Tier-2:** At the moment of writing, the recommend approach is to
  obtain a graphical connection by running a [NoMachine](https://docs.vscentrum.be/access/nx_start_guide.html#nomachine-nx-client-configuration) desktop on a login node.
- **Hortense Tier-1:** The recommended approach is to launch a desktop from the
  "Interactive Apps" pane on the [Tier-1 OnDemand portal](https://tier1.hpc.ugent.be).
  Since only the cryoSPARC master will run inside this desktop, there is no need
  to request a lot of resources (a few CPUs should suffice). On the other hand,
  do take into account that the cryoSPARC master needs to remain running while
  worker jobs are executed, so make sure to request the desktop for a
  sufficiently long time.

Another requirement is that you can access the files of this repository on
the cluster. This can be simply done by executing:

```git clone https://github.com/hpcleuven/cryoSPARC-VSC.git```

When the files in the repository are updated, you can synchronize your local
version by running

```git pull```

in the directory where you cloned the repository.

Finally you need a cryoSPARC license (which can be obtained for free for
academic usage [here](https://cryosparc.com/download)).

## Installing cryoSPARC

First you need to edit the file `set_environment.sh` and specify your
cryoSPARC license id and your credit account on the VSC. Optionally,
you can adapt the installation directory; on the Tier-2 clusters, somewhere in
`${VSC_DATA}` is probably the best option. On the Hortense Tier-1 cluster however,
it is better to use a directory in a subdirectory of `$VSC_SCRATCH_PROJECTS_BASE`
to which you have access, taking into account the specific recommendations
about installing software in a readonly mount point as explained
at https://docs.vscentrum.be/gent/tier1_hortense.html#accessing-software-via-readonly-mount-point

You can also set the directory where cryoSPARC will
do [SSD particle caching](https://guide.cryosparc.com/setup-configuration-and-management/software-system-guides/tutorial-ssd-particle-caching-in-cryosparc),
but the default value should be fine in most cases.

The installation of the cryoSPARC master can be done by running:

```bash install_cryosparc_master.sh```

This can take some time. During the actual installation, you will be prompted
to indicate some settings which should be self-explanatory. Because the
cryoSPARC master does not consume a lot of resources, it can be installed and
run on a login node. It is however also possible to do this on a compute node,
and typically you would use an interactive or debug partition for this end. One
thing to keep in mind is that when submitting jobs from within cryoSPARC, the
cryoSPARC master has to keep running as long as those jobs take. It is
therefore not a good idea to run the cryoSPARC master on compute nodes on which
you have a sufficiently long wall time.

> **_NOTE:_** If you try to run the cryoSPARC master on a node different from
the original installation, you might see errors. In that case, search for the
`config.sh` file in the installation directory and set the current new hostname
in the line `export CRYOSPARC_MASTER_HOSTNAME="XXX"`.

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
#SBATCH --account=<credit_account>
```

which you can submit with `sbatch install_cryosparc_worker.slurm`. If
everything goes well, the cryoSPARC worker will be installed in
`${SPARCDIR}/rocky8_skylake/cryosparc_worker`. Check the corresponding job
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
#SBATCH --account=<credit_account>
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
#SBATCH --account=<credit_account>
```

On the Tier-1 Hortense cluster you could use A100 GPUs from the `gpu_rome_a100`
partition. After executing `module swap cluster/dodrio/gpu_rome_a100`, you can
submit a job with the following header:

```
#SBATCH --job-name=install_cryosparc_worker
#SBATCH --nodes=1
#SBATCH --ntasks=12
#SBATCH --gpus-per-node=1
#SBATCH --time=01:00:00
#SBATCH --account=<credit_account>
```

> **_NOTE:_** It is not mandatory to have the worker installed for all types
of GPUs. It is perfectly fine to do this only for one specific type of GPU,
but in that case you will be limited to running jobs only for that type of GPU.
you have access.

## Starting and running the webserver

Now the cryoSPARC master process can be started by running

```cryosparcm start```

in a terminal. Since the cryoSPARC master process does not consume too much
resources, it should be ok to run this on a login node, but as mentioned earlier
you can also use a compute node. In both cases it is recommended to also run

```cryosparcm stop```

whenever you stop using cryoSPARC. Finally the ```cryosparcm status``` command
can help to troubleshoot in case of problems.

If all goes well, the command above should print an address at
which you can access the cryoSPARC web services. It looks as follows:

```http://tier2-p-login-3.genius.hpc.kuleuven.be:37160```

Note down this address for later. The port is set to the last 4 digits of your
VSC account with a 0 appended to it. You will need the port later on, so also
take note of that.

In case of problems, you can have a look at:
https://guide.cryosparc.com/setup-configuration-and-management/management-and-monitoring/cryosparcm

The actual heavy computational lifting will be done inside jobs submitted by the cryoSPARC
master process, and those jobs *need* to run on compute nodes.

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

This script currently only supports the KU Leuven Tier-2 clusters and the
Tier-1 Hortense cluster. Additional files need to be created in the
`cluster_info` directory in case you want to use yet another cluster.

### Using cryoSPARC

Now you can visit the address obtained after starting the cryoSPARC master
in a browser and login with the credentials specified when creating a cryoSPARC
user. There are a few different ways to do this.

The first option is to launch a browser on the node where you launched the
cryoSPARC master process. At the KU Leuven cluster, this can be done for
instance by opening a NoMachine desktop and simply using the browser installed
there. On Hortense, you can visit the [OnDemand platform](https://tier1.hpc.ugent.be)
and launch a Cluster Desktop there. This will allow you to open a browser on a
compute node, but you will be able to visit the webserver running at the login
node as well.

It is also possible to connect to the cluster with x-forwarding
(see https://docs.vscentrum.be/access/linux_client.html#x-server
and https://docs.vscentrum.be/access/using_the_xming_x_server_to_display_graphical_programs.html),
but often the interaction will not feel very responsive.

A third option is that you launch a browser on your local machine after
setting port forwarding to the cluster. First we will discuss the case where
you launched the cryoSPARC master on a login node. If your local machine runs
Linux, MacOS, or WSL inside Windows, it suffices to execute a command that
looks as follows:
```
ssh -L 37160:localhost:37160 vsc33716@login-genius.hpc.kuleuven.be
```
Of course you need to make sure to adapt the ports, username, and hostname to
your case.
If your local machine runs Windows, you can set up port forwarding with PuTTY. In
your regular connection to the cluster, go to "Connection/SSH/Tunnels". Add a
new forwarded port (in this example 37160) and use `localhost:37160` as the
destination with the "Local" radio button selected. Now open the connection
to start the port forwarding.

After the port forwarding has been set up correctly, you can simply visit `localhost:37160`
in a browser on your local machine and you will be able to access the cryoSPARC
webserver. From there you can follow the tutorial provided here:
https://guide.cryosparc.com/processing-data/cryo-em-data-processing-in-cryosparc-introductory-tutorial

In case the cryoSPARC master process runs on a compute node and you want to use
your local browser, you will need to use the login node as a jump host. The
command to do so looks as follows:
```
ssh -J vsc33716@tier1.hpc.ugent.be -L 37160:localhost:37160 debug53
```
This assumes your ssh configuration has been set up to use the correct public
key to access `tier1.hpc.ugent.be`. To achieve the same thing in PuTTY, have a
look at https://docs.vscentrum.be/access/setting_up_a_ssh_proxy_with_putty.html
