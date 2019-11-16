#!/bin/bash

set -euo pipefail

master_node_name="$1"

lxc launch ubuntu:18.04 $master_node_name --profile kubernetes
./lib/install-kubernetes.sh $master_node_name
./lib/start-master-node.sh $master_node_name
echo "KMASTER DEPLOYED"
