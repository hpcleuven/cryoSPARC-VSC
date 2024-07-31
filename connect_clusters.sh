#!/bin/bash

source set_environment.sh

if [ $VSC_INSTITUTE_CLUSTER == "dodrio" ]
then
    cluster_lanes="hortense-a100"
elif [ $VSC_INSTITUTE_CLUSTER == "genius" ] || [ $VSC_INSTITUTE_CLUSTER == "wice" ]
then
    cluster_lanes="genius-cpu genius-p100 genius-p100-debug genius-v100 wice-a100"
else
    echo "Unable to determine cluster lanes for VSC_INSTUTE_CLUSTER=$VSC_INSTITUTE_CLUSTER"
    exit 1
fi

for cluster in $cluster_lanes
do
    echo "Adding cluster lane $cluster"
    cp cluster_info/${cluster}.json cluster_info.json
    cp cluster_info/${cluster}.sh cluster_script.sh
    sed -i "s|__credit_account__|${CREDIT_ACCOUNT}|" cluster_script.sh
    sed -i "s|__ssd_path__|${SSD_PATH}|" cluster_script.sh
    sed -i "s|__worker_path__|${SPARCDIR}|" cluster_info.json
    cryosparcm cluster connect
    rm cluster_info.json cluster_script.sh
done
