#!/bin/bash -ex
#docker build --no-cache -t rezroo/docker-bench-security:1.0 .

while getopts ":R:T:" opt; do
    case "${opt}" in
        R)
            ResDir=$(pwd)/${OPTARG}
            oindex=$((OPTIND-1))
            ;;
        T)
            ImgTag=${OPTARG}
            oindex=$((OPTIND-1))
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

hn=$(hostname -s)

if [ -z ${ResDir+x} ]; then
   ResDir=$(pwd)/${hn}
fi

if [ -z ${ImgTag+x} ]; then
   ImgTag=debian
fi

CNAME=security-scan.${hn}

docker run -it --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -e TESTUID=$(id -u) -e TESTGID=$(id -g) \
    -v /etc:/etc:ro \
    -v /usr/bin/docker-containerd:/usr/bin/docker-containerd:ro \
    -v /usr/bin/docker-runc:/usr/bin/docker-runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    -v ${ResDir}:/scan/results \
    --label docker_bench_security \
    --name ${CNAME} \
    rezroo/security-scan:${ImgTag} -dmn $@

docker logs --details ${CNAME} > ${ResDir}/${hn}-scan.out

docker rm ${CNAME}