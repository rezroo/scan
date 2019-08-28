#!/bin/sh

# this script relies on us using different directories for each type of scan
# eg:
# /scan/results/k8s : our k8s scan
# /scan/results/docker : our docker scan

cur_dir=${1:-'/scan/results'}
prev_dir=${2:-'/scan/prev_results'}

cd /scan/jsondiff
for logfile in $(find ${cur_dir} -mindepth 2 -maxdepth 2 -name *.json); do
  logdir=$(dirname $logfile)
  filename=$(basename $logfile)
  scan_type=${logdir##*/} #/scan/results/docker/hostname.json -> docker
  ./run-docker-diff.sh $logfile ${prev_dir}/${scan_type} | tee ${cur_dir}/prev_diff-${scan_type}-${filename}
done
