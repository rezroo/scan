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
#   apt install --yes phython-pip && \

RUN \
   apt-get install -y wget && \
   apt-get install -y curl

# DEBUG
#RUN apt-get install -y vim less git

RUN \
   curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && \
   python get-pip.py && \
   pip install lxml

RUN mkdir /scan
WORKDIR /scan

ARG DBSDIR
COPY run-cis-scan.sh $DBSDIR docker-bench-security/

ARG JSONDIFF
COPY run-docker-diff.sh $JSONDIFF jsondiff/

ARG JSON2CSV
COPY csv-outline.json csv-docker-json.sh $JSON2CSV json2csv/

ARG OPENSCAP
COPY run-k8s-scan.sh $OPENSCAP/scap-content openscap/
#RUN mkdir -p openscap/results
COPY $OPENSCAP/scap-content/mirantis/cpe /usr/share/openscap/cpe

ARG XCCDF2JSON
COPY xccdf2json.sh $XCCDF2JSON xmlutils.py/

COPY run-scan.sh .

ENTRYPOINT ["/scan/run-scan.sh"]
CMD ["-dm"]
