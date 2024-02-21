#!/bin/bash

input_prefix_name() {
    read -p "Enter a node prefix(default $default_name_prefix): " name_prefix
    name_prefix="${name_prefix:-$default_name_prefix}"
}

input_worker_count() {
    read -p "Enter worker count(default $default_worker_count): " worker_count
    worker_count="${worker_count:-$default_worker_count}"
}

input_ssh_pubkey() {
    read -p "Enter a ssh pubkey name(default $default_ssh_pubkey): " ssh_pubkey
    ssh_pubkey="${ssh_pubkey:-$default_ssh_pubkey}"

    if [ -f "$ssh_pubkey" ]; then
        echo "ssh pub key exist"
    else
        echo "ssh pub key not exist"
        echo "******************************************"
        echo "**            Create an ssh key         **"
        echo "******************************************"
        echo "run `ssh-keygen -C ubuntu -f $ssh_pubkey`"
    fi
}

input_ssh_cloud_init_file() {
    read -p "Enter a ssh pubkey name(default $default_cloud_init_file): " cloud_init_file
    cloud_init_file="${cloud_init_file:-$default_cloud_init_file}"

    if [ -f "$cloud_init_file" ]; then
        echo "cloud_init_file exist"
    else
        echo "$cloud_init_file not exist"
        echo "******************************************"
        echo "**        Create a cloud init file      **"
        echo "******************************************"
        pub_key_str=$(cat "$ssh_pubkey".pub)
        echo "Create $cloud_init_file"
        export pub_key_str=$pub_key_str
        cat template/cloud_init.template.yaml| envsubst > $cloud_init_file
    fi
}

input_mount_folder(){
    read -p "Enter mount folder(default $default_folder_path): " mount_folder
    mount_folder="${mount_folder_path:-$default_folder_path}"
    if [ ! -d "$mount_folder" ]; then
        mkdir -p "$mount_folder"
        echo "Folder '$mount_folder' created."
    fi
}

update_key_value() {
    local key=$1
    local value=$2

    default_values_file="default_values_2.conf"

    if [ -e "$default_values_file" ]; then
        if grep -q "^$key=" "$default_values_file"; then
            sed -e "s/$key=.*/$key=\"$value\"\g" $default_values_file > $default_values_file
        else
            echo "$key=$value" >> "$default_values_file"
        fi
    else
        echo "$key=$value" > "$default_values_file"
    fi
}

update_default_values() {
    export default_name_prefix=$name_prefix
    export default_worker_count=$worker_count
    export default_ssh_pubkey=$ssh_pubkey
    export default_cloud_init_file=$cloud_init_file
    export default_folder_path=$mount_folder

    default_values_file="default_values.conf"

    cat template/default_values.template.conf| envsubst > $default_values_file

}

execute() {
    input_prefix_name
    input_worker_count
    input_ssh_pubkey
    input_ssh_cloud_init_file
    input_mount_folder

    update_default_values
}

execute