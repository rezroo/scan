#!/bin/bash

#This script will run one or more of our scans twice, once as a bash script and then as a container
#Results are saved in all-scan-resultz.tgz
#The reason for saving results under a directory named as hostname is to allow combining all the scans
#from all the hosts by just copying them into one directory without having to jump through hoops


function usage() {
  cat <<EOF
This script will run one or more of our scans twice, once as a bash script and then as a container
Results are saved in all-scan-resultz.tgz

options:
  -d: Run docker bench scan in host and container.
  -c: Quick docker scan
  -k: Run kubernetes scan
  -i: Install oscap on host (if it is not already installed)
EOF
  exit 1
}


source ./bash_utils/hook.sh

# only these hooks will run in this order
hook_order init install_oscap k8s_scan docker_bench_scan tar
# they must first be enabled though
enable_hooks init tar


while getopts ":dkic" opt; do
  hasopts=1
  case "${opt}" in
    c)
      set_hook "docker_bench_scan" -c host_configuration,docker_daemon_configuration
      ;;
    d)
      set_hook "docker_bench_scan"
      ;;
    k)
      #TODO check if oscap is installed and add a flag
      # which can toggle whether or not to install it
      set_hook "k8s_scan"
      ;;
    i)
      set_hook "install_oscap"
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z $hasopts ]; then
  usage
fi


#TODO: put this all in a source file
CWD=$(pwd)
HN=$(hostname -s)
HOST_LOG_DIR=${CWD}/${HN}/host
HOST_K8S_DIR=${HOST_LOG_DIR}/k8s
DOCKER_BENCH_REPO="${CWD}/docker-bench-security.git"
XCCDF_REPO="${CWD}/xccdf-benchmarks/scap-content/"
HOST_CPE_FILE="/usr/share/openscap/cpe/openscap-cpe-dict.xml"

# first set up host directories
function _run_init() {
  mkdir -p ${HOST_LOG_DIR}
  mkdir -p ${HOST_K8S_DIR}
  mkdir -p ${CWD}/${HN}/docker
  mkdir -p ${CWD}/${HN}/k8s
}


function _run_install_oscap() {
  sudo apt-get install --yes libopenscap8
  if [ $? != 0 ]; then
    echo "Could not install oscap"
    exit 1
  fi
}


function _run_docker_bench_scan() {
  #TODO allow this to be passed in from host-compare.sh
  if [ -z "$1" ]; then
    ARGS="-c host_configuration,docker_daemon_configuration,docker_daemon_files,container_images,container_runtime,docker_security_operations"
  else
    ARGS=$@
  fi

  # host scan
  cd ${DOCKER_BENCH_REPO}
  ./docker-bench-security.sh -l ${HOST_LOG_DIR}/${HN}.log $ARGS
  cd -

  # container scan while passing along the '-m' flag to perform diff
  ./run-docker-scan.sh -R $HN -dm -l /scan/results/docker/${HN}.log $ARGS

}


function _run_k8s_scan() {
  echo "Running k8s scan on host"

  cd ${XCCDF_REPO}
  # Ensure HOSTNAME is set for the k8s scan
  export HOSTNAME=${HN}
  ${CWD}/container_utils/run-k8s-scan.sh ${HOST_K8S_DIR}
  res=$@
  cd -

  # run container stuff
 ./run-docker-scan.sh -R $HN -kxb -l /scan/results/k8s/${HOSTNAME}.xml
}


function _run_tar() {
    tar zcvf ${HN}-scan-resultz.tgz ${HN} >/dev/null 2>&1
}

run_hooks
