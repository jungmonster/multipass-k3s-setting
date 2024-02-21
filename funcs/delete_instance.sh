#!/bin/bash

delete_worker_node() {
    echo "==============================================="
    echo "delete work node                              "
    echo "currnet worker count:             $default_worker_count" 
    for ((i=1; i<=$default_worker_count; i++))
    do
        multipass delete k3s-node$i
    done
}

delete_master_node() {
    echo "==============================================="
    master_name=$default_name_prefix"-master"
    echo "delete master node:               $master_name "
    multipass delete $master_name
}

multipass_purge() {
    echo "==============================================="
    echo "multipass purge"
    multipass purge

}

execute() {
    delete_worker_node
    delete_master_node
    multipass_purge
}

execute