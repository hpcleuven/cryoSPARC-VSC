#!/bin/bash

export LICENSE_ID=
export SPARCDIR=${VSC_DATA}/apps/${VSC_INSTITUTE_CLUSTER}/cryoSPARC
export CREDIT_ACCOUNT=
# prepare SSD setup
cd ${VSC_SCRATCH_NODE}
test -d ./ssddir || lfs setstripe -E -1 --pool=ssd -c 4 -S 1M ssddir
export SSD_PATH='${VSC_SCRATCH_NODE}/ssddir'

# Do not edit below
export PATH=${SPARCDIR}/cryosparc_master/bin:$PATH
