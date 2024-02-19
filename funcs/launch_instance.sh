#!/bin/bash


launch_master_node() {
    # echo "==============================================="
    echo "launch master node:               $master_node "
 
    create_master_instance
    update_ssh_config
    install_k3s_master
}

launch_worker_node() {
    create_worker_instance
    install_k3s_worker
}

create_master_instance() {
    master_node="$default_name_prefix-master"
    multipass launch -n $master_node -c 2 -m 2G -d 20G --cloud-init ~/$cloud_init_file jammy
}

update_ssh_config() {
    config_file="$HOME/.ssh/config"

    info=$(multipass info k3s-master)
    master_ipv4=$(echo "$info" | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | head -n1)
    echo
    echo "master node ipv4: $master_ipv4"

    if grep -q "^Host $master_node$" "$config_file"; then
        sed -i '' "/^Host $master_node$/,/^$/ s/^ *HostName .*$/HostName $master_ipv4/" $config_file
    else
        # 호스트가 존재하지 않는 경우 정보 추가
        echo "Host $master_node does not exist in $config_file. Adding..."
        echo -e "\nHost $master_node" >> "$config_file"
        echo "  HostName $master_ipv4" >> "$config_file"
        echo "  User username" >> "$config_file"
        echo "  Port 22" >> "$config_file"
        # 원하는 설정 추가할 수 있음vimg_file."
    fi
}

install_k3s_master() {
    echo 
    echo "==============================================="
    echo "install k3s"
    multipass exec $master_node  -- /bin/bash -c "curl -sfL https://get.k3s.io | sh -"
}

create_worker_instance() {
    echo "==============================================="
    echo "launch work node                              "
    echo "currnet worker count:             $worker_count" 
    for ((i=1; i<=$worker_count; i++))
    do
        multipass launch -n k3s-node$i -c 2 -m 2G -d 20G jammy
    done
}

install_k3s_worker() {
    master_token=$(multipass exec k3s-master -- /bin/bash -c "sudo cat /var/lib/rancher/k3s/server/node-token")
    echo "==============================================="
    echo "master node token: $master_token"

    echo "==============================================="
    echo "install work node"
    for ((i=1; i<=$worker_count; i++))
    do
        echo "running work node $i"
        multipass exec k3s-node$i -- /bin/bash -c "curl -sfL https://get.k3s.io | K3S_TOKEN=\"$master_token\" K3S_URL=https://$master_ipv4:6443 sh -" 
    done

}


init_k3s_setting() {
    echo
    echo "==============================================="
    echo "init setting"
    master_node="$default_name_prefix-master"
    multipass exec $master_node -- /bin/bash -c "export KUBECONFIG=~/.kube/config"
    multipass exec $master_node -- /bin/bash -c "mkdir ~/.kube 2> /dev/null"
    multipass exec $master_node -- /bin/bash -c "sudo k3s kubectl config view --raw > ~/.kube/config"
    multipass exec $master_node -- /bin/bash -c "chmod 600 ~/.kube/config"
    multipass exec $master_node -- /bin/bash -c "sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && chown ubuntu ~/.kube/config && chmod 600 ~/.kube/config && export KUBECONFIG=~/.kube/config"
    multipass exec $master_node -- /bin/bash -c "sudo chmod 644 /etc/rancher/k3s/k3s.yaml"
}

mount_folder () {
    echo "mount $mount_folder"
    multipass mount $mount_folder k3s-master:~/study_resource 
}

execute() {
    master_node="$default_name_prefix-master"
    launch_master_node
    launch_worker_node
    init_k3s_setting
    mount_folder
}



execute