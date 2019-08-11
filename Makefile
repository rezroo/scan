.PHONY: help $(App)


NoCache=--no-cache
OPTS=
App=security-scan
AppRepo=https://github.com/rezroo
RepoBranch=-b auto-nc
AppVersion=debian
AppImage=$(App):$(AppVersion)
DUser=rezroo
Host=$(shell hostname)

Anal=docker-bench-analysis

%.git :
	if [ ! -d  $@ ]; then (git clone $(RepoBranch) $(AppRepo)/$@ $@); fi

# build the container image
$(App): docker-bench-security.git json2csv.git jsondiff.git xmlutils.py.git
	#cd $(App).git; git pull
	docker build $(OPTS) \
    --build-arg  DBSDIR=docker-bench-security.git  \
    --build-arg  JSONDIFF=jsondiff.git  \
    --build-arg  JSON2CSV=json2csv.git  \
    --build-arg  OPENSCAP=xccdf-benchmarks \
    --build-arg  XCCDF2JSON=xmlutils.py.git \
    -t $(DUser)/$(App):$(AppVersion) -f Dockerfile .

# comapre host docker-bench-security with the containerized version
runscan:
	./run-docker-scans.sh

# test the scripts running host docker-bench-security with the containerized version
runquickcompare:
	./run-docker-scans.sh -c host_configuration,docker_daemon_configuration

# test the scripts to do a docker scan and generate csv files from the json
runquicktest:
	./run-docker-scan.sh -R testscan -l /scan/results/docker/${Host}.log -c host_configuration,docker_daemon_configuration,docker_daemon_files

rundebugsession:
	docker rm -f dbg-sec-scan | true
	./dbg-sec-scan.sh
	docker exec -it dbg-sec-scan bash

runk8sscan:
	./run-docker-scan.sh -R testscan -k -l /scan/results/docker/${Host}.log

makek8sjson:
	./run-docker-scan.sh -R testscan -kx -l /scan/results/docker/${Host}.log

# run the complete scan
runallscans:
	./run-docker-scan.sh -R $(Host) -dnkx -l /scan/results/docker/${Host}.log -c host_configuration,docker_daemon_configuration,docker_daemon_files,container_images,container_runtime,docker_security_operations

