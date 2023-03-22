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

## Installing cryoSPARC

First you need to edit the file `set_environment.sh` and specify your
cryoSPARC license id and your credit account on the VSC (for example,
`default_project` if you want to use the introduction credits). Optionally,
you can adapt the installation directory but somewhere in ${VSC_DATA} is
probably the best option. You can also set the directory where cryoSPARC will
do SSD particle caching (see
https://guide.cryosparc.com/setup-configuration-and-management/software-system-guides/tutorial-ssd-particle-caching-in-cryosparc).


Nex you need to download the installation files:

```bash download_cryosparc.sh```

Next, the installation can be done automatically with

```bash install_cryosparc.sh```

This can take some time. During the actual installation, you will be prompted
to indicate some settings which should be self-explanatory.

## Starting and running the webserver

Now the cryoSPARC master process can be started by running

```cryosparcm start```

If all goes well, this should print an address at which you can access the
cryoSPARC web services. It looks as follows:

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
