#!/bin/bash

set -euo pipefail

readonly runc_version="v1.0.0-rc9"
readonly crio_version="v1.15.2"

readonly crio_wrk_dir="/tmp/crio"
readonly runc_wrk_dir="/tmp/runc"

node_name="$1"

download_runc() {
  mkdir $runc_wrk_dir
  cd $runc_wrk_dir
  wget "https://github.com/opencontainers/runc/releases/download/${runc_version}/runc.amd64"
  chmod +x runc.amd64
}

install_runc() {
  lxc file push "$runc_wrk_dir/runc.amd64" "$1/usr/bin/runc"
  cat <<EOF | lxc exec "$1" bash
which runc
runc --version
EOF
}

download_crio() {
  mkdir -p $crio_wrk_dir
  cd $crio_wrk_dir
  wget "https://files.schu.io/pub/cri-o/crio-amd64-${crio_version}.tar.gz"
  tar -xzf "crio-amd64-${crio_version}.tar.gz"
}

install_crio() {
  cat <<EOF | lxc exec "$1" bash
mkdir -p /tmp/crio
EOF
  
  lxc file push "$crio_wrk_dir/"* "$1/tmp/crio/"
  
  cat <<EOF | lxc exec "$1" bash
cd /tmp/crio
ls
cp crio /usr/local/bin/
which crio
crio --version
mkdir -p /usr/local/libexec/crio
cp {pause,conmon} /usr/local/libexec/crio/
mkdir -p /etc/crio
cp {crio.conf,crictl.yaml,crio-umount.conf,policy.json} /etc/crio/
mkdir -p /etc/containers
ln -s /etc/crio/policy.json /etc/containers/policy.json
mkdir -p /etc/cni/net.d
cat >/etc/systemd/system/crio.service <<CRIO_UNIT
[Unit]
Description=CRI-O daemon
[Service]
ExecStart=/usr/local/bin/crio --runtime /usr/bin/runc --registry docker.io
Restart=always
RestartSec=10s
[Install]
WantedBy=multi-user.target
CRIO_UNIT
systemctl daemon-reload
systemctl -q enable crio
systemctl start crio
systemctl status crio
EOF
}

install_kubernetes() {
  cat <<EOF | lxc exec "$1" bash
apt-get update && apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<IEOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
IEOF
apt-get update
apt-get install -y kubelet kubeadm kubectl
which kubelet
kubelet --version
which kubeadm
kubeadm version
which kubectl
EOF
}

echo "NODE_NAME: $node_name"

echo "INSTALLING RUNC"
if [ ! -d "$runc_wrk_dir" ]; then
  download_runc
fi
install_runc $node_name

echo "INSTALLING CRIO"
if [ ! -d "$crio_wrk_dir" ]; then
  download_crio
fi
install_crio $node_name

echo "INSTALLING KUBERNETES"
install_kubernetes $node_name
