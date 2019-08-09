#!/bin/bash -ex

#This script will run the docker-bench-security twice, once as a bash script and then as a container
#Results are saved in all-scan-resultz.tgz
#The reason for saving results under a directory named as hostname is to allow combining all the scans
#from all the hosts by just copying them into one directory without having to jump through hoops

cwd=$(pwd)
hn=$(hostname -s)
dn=docker-bench-security.git

if [ -z "$1" ]; then
  ARGS="-c host_configuration,docker_daemon_configuration,docker_daemon_files,container_images,container_runtime,docker_security_operations"
else
  ARGS=$@
fi

hostlogdir=${cwd}/${hn}/host
mkdir -p ${hostlogdir}
mkdir -p ${cwd}/${hn}/docker


cd ${dn}
./docker-bench-security.sh -l ${hostlogdir}/${hn}.log $ARGS
cd ..

./run-docker-scan.sh -R $hn -dm -l /scan/results/docker/${hn}.log $ARGS

tar zcvf ${hn}-scan-resultz.tgz ${hn}
#rm -rf ${dn}
