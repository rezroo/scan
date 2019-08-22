#!/bin/bash -ex
#docker build --no-cache -t rezroo/docker-bench-security:1.0 .

while getopts ":R:T:K:Ddmnkxb" opt; do
    case "${opt}" in
        R)
            ResDir=$(pwd)/${OPTARG}
            oindex=$((OPTIND-1))
            ;;
        T)
            ImgTag=${OPTARG}
            oindex=$((OPTIND-1))
            ;;
        D)
            DEBUG=1
            oindex=$((OPTIND-1))
            ;;
        K)
            KUBE_CONFIG_DIR=${OPTARG}
            oindex=$((OPTIND-1))
            ;;
        [dmnkxbo]) # if caller provides command options then don't add
               # default running option of -dn
            HasOptions=1
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

if [ -z ${HasOptions+x} ]; then
   CMDArgs="-dn"
fi

if [ -z "${SUDO_UID}" ]; then
   TESTUID=$(id -u)
   TESTGID=$(id -g)
else
   TESTUID=$SUDO_UID
   TESTGID=$SUDO_GID
fi

CNAME=security-scan.${hn}

DOCKER_ARGS=(-t --net host --pid host --userns host --cap-add audit_control \
    -e DOCKER_CONTENT_TRUST=$DOCKER_CONTENT_TRUST \
    -e TESTUID=$TESTUID -e TESTGID=$TESTGID \
    -v /etc:/etc:ro \
    -v /usr/bin/docker-containerd:/usr/bin/docker-containerd:ro \
    -v /usr/bin/docker-runc:/usr/bin/docker-runc:ro \
    -v /usr/lib/systemd:/usr/lib/systemd:ro \
    -v /var/lib:/var/lib:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    --label docker_bench_security \
)

if [ ${KUBE_CONFIG_DIR+x} ]; then
  if [ ! -d $KUBE_CONFIG_DIR ]; then
    echo "Could not find kube config dir at ${KUBE_CONFIG_DIR}!" >&2
    exit 1
  fi
  DOCKER_ARGS+=(-v ${KUBE_CONFIG_DIR}:/root/.kube:ro)
fi

if [ ${DEBUG+x} ]; then
  CNAME=dbg-sec-scan
  docker rm -f ${CNAME} | true

  DOCKER_ARGS+=(-d \
    -v $(pwd)/dbg-scan:/scan/results \
    -v $(pwd):/root/src \
    --name ${CNAME} \
    --entrypoint "/bin/sh" \
    rezroo/security-scan:debian -c "sleep 3600"
  )
else
  DOCKER_ARGS+=(-i \
    -v ${ResDir}:/scan/results \
    --name ${CNAME} \
    rezroo/security-scan:${ImgTag} $CMDArgs $@
  )
fi

docker run "${DOCKER_ARGS[@]}"

if [ ${DEBUG+x} ]; then
  docker exec -it dbg-sec-scan bash
fi

docker logs --details ${CNAME} > ${ResDir}/${hn}-scan.out

if [ -z ${DEBUG+x} ]; then
  docker rm ${CNAME}
fi
