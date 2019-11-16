#!/bin/bash

set -euo pipefail

readonly crio_wrk_dir="/tmp/crio"
readonly runc_wrk_dir="/tmp/runc"
readonly joincmd_wrk_dir="/tmp/kube-join"


echo "CLEANING UP"
rm -rf "$runc_wrk_dir" "$crio_wrk_dir"

