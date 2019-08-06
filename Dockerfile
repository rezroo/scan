FROM ubuntu:xenial

#LABEL docker-bench-security="docker-bench-security"
#LABEL org.label-schema.name="docker-bench-security" \
#      org.label-schema.url="https://github.com/konstruktoid/docker-bench-security" \
#      org.label-schema.vcs-url="https://github.com/konstruktoid/docker-bench-security.git"

RUN \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install auditd ca-certificates docker.io gawk iproute2 procps --no-install-recommends && \
   apt-get -y install jq && \
   apt-get install -y python && \
   apt-get install --yes libopenscap8 && \
    apt-get -y clean && \
    apt-get -y autoremove && \
    true

#   rm -rf /var/lib/apt/lists/* \
#     /usr/share/doc /usr/share/doc-base \
#     /usr/share/man /usr/share/locale /usr/share/zoneinfo

#   apt-get install -y wget && \
#   apt-get install -y curl && \

RUN mkdir /scan
WORKDIR /scan

ARG DBSDIR
COPY $DBSDIR docker-bench-security

ARG JSONDIFF
COPY $JSONDIFF jsondiff

ARG OPENSCAP
COPY $OPENSCAP/scap-content openscap
RUN mkdir -p openscap/results
COPY $OPENSCAP/scap-content/mirantis/cpe /usr/share/openscap/cpe

COPY run-cis-scan.sh docker-bench-security/
COPY run-docker-diff.sh jsondiff/
COPY run-k8s-scan.sh openscap/
COPY run-scan.sh .

ENTRYPOINT ["/scan/run-scan.sh"]
CMD ["-dm"]
