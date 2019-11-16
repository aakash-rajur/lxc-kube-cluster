#!/bin/bash

set -euo pipefail

readonly joincmd_wrk_dir="/tmp/kube-join"

master_node_name="$1"
worker_count="${2-}"

if [[ -z "$worker_count" ]]; then
  worker_count=1
fi

if [ -d "$joincmd_wrk_dir" ]; then
  rm -rf "$joincmd_wrk_dir"
fi


for (( worker = 1; worker <= $worker_count; worker++ )); do 
  worker_node_name="kworker$worker"
  lxc launch ubuntu:18.04 "$worker_node_name" --profile kubernetes
  ./lib/install-kubernetes.sh "$worker_node_name"
  ./lib/start-worker-node.sh "$master_node_name" "$worker_node_name"
done

