#!/bin/bash

source set_environment.sh

for cluster in genius-cpu genius-p100 genius-p100-debug genius-v100 wice-a100 dodrio-gpu-rome-a100-40
do
    cp cluster_info/${cluster}.json cluster_info.json
    cp cluster_info/${cluster}.sh cluster_script.sh
    sed -i "s|__credit_account__|${CREDIT_ACCOUNT}|" cluster_script.sh
    sed -i "s|__ssd_path__|${SSD_PATH}|" cluster_script.sh
    sed -i "s|__worker_path__|${SPARCDIR}|" cluster_info.json
    cryosparcm cluster connect
    rm cluster_info.json cluster_script.sh
done
