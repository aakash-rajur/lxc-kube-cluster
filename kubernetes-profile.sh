#!/bin/bash

set -euo pipefail

lxc profile create kubernetes
lxc profile edit kubernetes <<PROFILE
config:
  limits.cpu: "2"
  limits.memory: 4GB
  linux.kernel_modules: ip_tables,ip6_tables,netlink_diag,nf_nat,overlay
  raw.lxc: |-
    lxc.apparmor.profile=unconfined
    lxc.mount.auto=proc:rw sys:rw cgroup:rw
    lxc.cgroup.devices.allow=a
    lxc.cap.drop=
    lxc.apparmor.allow_incomplete=1
  security.nesting: "true"
  security.privileged: "true"
description: kubernetes node lxc profile
devices:
  eth0:
    name: eth0
    nictype: bridged
    parent: lxdbr0
    type: nic
  kmsg:
    path: /dev/kmsg
    source: /dev/kmsg
    type: unix-char
  root:
    path: /
    pool: default
    type: disk
PROFILE

lxc profile show kubernetes
