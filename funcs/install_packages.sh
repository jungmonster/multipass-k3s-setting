install_helm () {
    master_node="$default_name_prefix-master"

    # https://helm.sh/docs/intro/install/
    multipass exec $master_node -- /bin/bash -c "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3"
    multipass exec $master_node -- /bin/bash -c "chmod 700 get_helm.sh"
    multipass exec $master_node -- /bin/bash -c "./get_helm.sh"
}

execute() {
    
    install_helm
}



execute