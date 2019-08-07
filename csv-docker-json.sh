#!/bin/sh
set -ex

if [ -z "$1" ]; then
   SCANDIR=/scan/results/docker
else
   SCANDIR=$1
fi

if [ -z "$2" ]; then
   CSVDir=${SCANDIR}/$HOSTNAME
else
   CSVDir=${SCANDIR}/$2
fi

gen_csv() {
  file=$1
  outline=$2
  for i in $(seq 0 5)
  do
    jq ".tests[$i]" $file | ./json2csv.py -o ${CSVDir}/sec-$(($i+1)).csv - $outline
  done
}

# main program
mkdir -p ${CSVDir} || true
gen_csv ${SCANDIR}/${HOSTNAME}.log.json csv-outline.json
