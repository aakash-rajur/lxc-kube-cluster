# lxc-kube-cluster

lxc configuration to deploy local kubernetes cluster

## prerequisites
1. install [lxc](https://linuxcontainers.org/lxc/getting-started/) for your specific platform
2. install wget for your platform if not already

## usage
1. `git clone https://github.com/aakashRajur/lxc-kube-cluster.git`
2. `cd lxc-kube-cluster`
3. `./create-cluster.sh $NO_OF_WORKER_NODES` where  `$NO_OF_WORKER_NODES` if not present
   will default to 2.
4. `lxc list` should show you your deployed cluster
5. use `lxc stop $CONTAINER_NAME` where `$CONTAINER_NAME` can be any of `kmaster`, `kworker1`, 
   `kworker2` until the no of workers specified in `$NO_OF_WORKER_NODES`. 
```
stop workers vms before master vm
```
6. use `lxc start $CONTAINER_NAME` where `$CONTAINER_NAME` can be any of `kmaster`, `kworker1`,
   `kworker2` until the no of workers specified in `$NO_OF_WORKER_NODES`
```
start master vm before worker vm
```
7. `start-cluster.sh` should copy over kube-config to the host machine, if not use 
   `lxc file pull kmaster/root/.kube/config  ~/.kube/` to do so. 
8. your `kubectl` should work correctly now

