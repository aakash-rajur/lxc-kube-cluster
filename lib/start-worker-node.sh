#!/bin/bash

set -euo pipefail

master_node_name="$1"
worker_node_name="$2"

echo "$master_node_name-$worker_node_name"

readonly joincmd_wrk_dir="/tmp/kube-join"

procure_joincmd() {
  echo $(cat <<EOF|lxc exec "$1" bash
kubeadm token create --print-join-command
EOF
)
}

joincmd=$(procure_joincmd "$master_node_name")
cat <<EOF|lxc exec "$worker_node_name" bash
echo "$joincmd" > joincommand.sh
chmod +x joincommand.sh
./joincommand.sh
EOF

