#!/bin/bash

set -euo pipefail

node_name="$1"

start_master_node() {
  cat <<EOF | lxc exec "$1" bash
  kubeadm init --apiserver-advertise-address=$(hostname -i | awk '{print $2}') --ignore-preflight-errors=all
systemctl status kubelet --no-pager --lines=0
EOF
}

configure_kubectl() {
  cat <<EOF | lxc exec "$1" bash
mkdir -p \$HOME/.kube
cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config
chown \$(id -u):\$(id -g) \$HOME/.kube/config
kubectl get nodes
EOF
}

configure_network_interface() {
  cat <<EOF | lxc exec "$1" bash
  kubectl apply -f https://docs.projectcalico.org/v3.8/manifests/calico.yaml
EOF
}

create_joincommand() {
  cat <<EOF | lxc exec "$1" bash
cd \$HOME
joincommand=\$(kubeadm token create --print-join-command)
echo "\$joincommand --ignore-preflight-errors=all" > joincommand.sh
chmod +x joincommand.sh
EOF
}

echo "STARTING MASTER NODE"
start_master_node $node_name
configure_kubectl $node_name
configure_network_interface $node_name

echo "CREATING JOINCOMMAND"
create_joincommand $node_name

echo "MASTER INITIALIZED"

