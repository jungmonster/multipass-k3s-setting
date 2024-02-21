#!/bin/bash

# read default values
DEFAULT_VALUES="default_values.conf"


source $DEFAULT_VALUES

source funcs/init_check.sh

source funcs/input_values.sh

source funcs/launch_instance.sh

source funcs/install_packages.sh