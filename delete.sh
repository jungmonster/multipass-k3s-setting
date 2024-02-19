#!/bin/bash


multipass delete k3s-master
multipass delete k3s-node1
multipass delete k3s-node2

multipass purge