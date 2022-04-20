#!/bin/bash

source set_environment.sh

for cluster in genius-p100 genius-p100-debug
do
    cp cluster_info/${cluster}.json cluster_info.json
    cp cluster_info/${cluster}.sh cluster_script.sh
    sed -i "s/__credit_account__/${CREDIT_ACCOUNT}/" cluster_script.sh
    cryosparcm cluster connect
    rm cluster_info.json cluster_script.sh
done
