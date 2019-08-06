#!/bin/sh
set -x
echo $@

# This script assumes the following container directory structure:
# /scan/results for all final output
# /scan/docker-bench-security
# /scan/jsondiff
# /scan/openscap

docker version
#kubectl version

# Options for running various scans:
# -d : run docker-bench-security
# -m : compare /scan/results/docker with /scan/results/host (assumed to be there) for differences.
# -a : generate .csv files for the docker results
# -k : run k8s openscap scan
# -u : run ubuntu openscap scan
# -x : generate json from k8s xccdf files
while getopts ":dml:" opt; do
  case "${opt}" in
    d)
      DockerBench=1
      oindex=$((OPTIND-1))
      ;;
    m)
      DockerCompare=1
      oindex=$((OPTIND-1))
      ;;
    l)
      logfile=${OPTARG}
      ;;
    :)
      echo "Option $opt and -$OPTARG requires an argument." >&2
      exit 1
      ;;
    \?)
      #echo "Invalid option $opt and $OPTARG"
      ;;
  esac
done
if [ ! -z ${oindex+x} ]; then
    shift $oindex
fi

if [ ! -z ${DockerBench+x} ]; then
  mkdir /scan/results/docker
  cd /scan/docker-bench-security
# ./run-cis-scan.sh -l /scan/results/docker/${HOSTNAME}.log
#    -c host_configuration,docker_daemon_configuration,docker_daemon_files,container_images,container_runtime,docker_security_operations
  ./run-cis-scan.sh $@
fi

if [ ! -z ${DockerCompare+x} ]; then
  cd /scan/jsondiff
  ./run-docker-diff.sh /scan/results/host /scan/results/docker $HOSTNAME | tee /scan/results/diff-${HOSTNAME}-docker.json
fi

chown -R ${TESTUID}:${TESTGID} /scan/results
