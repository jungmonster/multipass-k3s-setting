#!/bin/bash


check_install_multipass() {
    if command -v multipass &> /dev/null
    then
        echo "Multipass is installed."
    else
        echo "Multipass is not installed. Please install it.(https://multipass.run/install)"
        exit 1
    fi
}

check_exist_instance() {
    list_output=$(multipass list)
    names=($(echo "$list_output" | awk '{print $1}'))
    found_master=false
    master_name=$default_name_prefix"-master"

    for name in "${names[@]}"; do
        if [ "$name" == $master_name ]; then
            found_master=true
            break
        fi
    done

    if [ "$found_master" == true ]; then
        read -p "'master' instance found. Do you want to delete it and proceed? (y/n): " choice
        if [ "$choice" == "y" ]; then
            echo "Proceeding with further steps after deleting 'master' instance."
            source funcs/delete_instance.sh
        else
        # 삭제하지 않고 종료
            echo "Exiting script without deleting 'master' instance."
            exit 0
        fi
    else
        echo "Master node not found. Start k3s setting."
    fi
}



execute(){
    check_install_multipass
    check_exist_instance
}

execute