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
	./host-compare.sh -d

# test the scripts running host docker-bench-security with the containerized version
runquickcompare:
	./host-compare.sh -c

# test the scripts to do a docker scan and generate csv files from the json
runquicktest:
	./run-docker-scan.sh -R testscan -l /scan/results/docker/${Host}.log -c host_configuration,docker_daemon_configuration,docker_daemon_files

rundebugsession:
	./run-docker-scan.sh -D

runk8sscan:
	./run-docker-scan.sh -R testscan -k -l /scan/results/docker/${Host}.log

makek8sjson:
	./run-docker-scan.sh -R testscan -kx -l /scan/results/docker/${Host}.log

makek8scsv:
	./run-docker-scan.sh -kxo -l /scan/results/k8s/k8s-master.json

# run the complete scan
runallscans:
	./run-docker-scan.sh -R $(Host) -dnkx -l /scan/results/docker/${Host}.log -c host_configuration,docker_daemon_configuration,docker_daemon_files,container_images,container_runtime,docker_security_operations

