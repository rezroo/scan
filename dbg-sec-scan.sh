#!/bin/bash -ex
if [ -z "$1" ]; then
   SDir=$(pwd)
else
   SDir=$1
fi

ResDir=dbg-scan

docker run -dt --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -e TESTUID=$(id -u) -e TESTGID=$(id -g) \
    -v /etc:/etc:ro \
    -v /usr/bin/docker-containerd:/usr/bin/docker-containerd:ro \
    -v /usr/bin/docker-runc:/usr/bin/docker-runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v ${ResDir}:/scan/results \
    -v ${SDir}:/root/src \
    --label docker_bench_security \
    --name dbg-sec-scan \
    --entrypoint "/bin/sh" \
    rezroo/security-scan:debian -c "sleep 3600"

