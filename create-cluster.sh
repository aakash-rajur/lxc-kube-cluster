#!/bin/bash

set -euo pipefail

readonly master_node_name=kmaster
worker_count="${1-}"

if [[ -z "$worker_count" ]]; then
  worker_count=2
fi

./kubernetes-profile.sh
./create-master.sh "$master_node_name"
./create-workers.sh "$master_node_name" "$worker_count"


echo "DOWNLOADING KUBE CONFIG"
lxc file pull "$master_node_name/root/.kube/config" "~/.kube/"
./lib/cleanup.sh
