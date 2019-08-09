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

$(App): docker-bench-security.git json2csv.git jsondiff.git
	#cd $(App).git; git pull
	docker build $(OPTS) \
    --build-arg  DBSDIR=docker-bench-security.git  \
    --build-arg  JSONDIFF=jsondiff.git  \
    --build-arg  JSON2CSV=json2csv.git  \
    --build-arg  OPENSCAP=mirantis-xccdf-benchmarksxccdf-benchmarks  \
    -t $(DUser)/$(App):$(AppVersion) -f Dockerfile .

runscan:
	./run-docker-scans.sh

runquickscan:
	./run-docker-scans.sh -c host_configuration,docker_daemon_configuration

#	./$(App).git/run-docker-scan.sh -R $(Host) -l $(Host).log -c host_configuration,docker_daemon_configuration,docker_daemon_files,container_images,container_runtime,docker_security_operations


$(Anal): json2csv.git jsondiff.git
#	cd $(App).git; docker build $(OPTS) -t $(DUser)/$(App):$(AppVersion) -f distros/Dockerfile.$(AppVersion) .

runanal:
	./run-docker-scan.sh


