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



execute(){
    check_install_multipass
}

execute