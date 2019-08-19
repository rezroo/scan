#!/bin/sh
set -ex

if [ -z "$1" ]; then
   logfile=/scan/results/docker/${HOSTNAME}.log.json
else
   logfile=${1}.json
fi

SCANDIR=$(dirname $logfile)
CSVDir=${SCANDIR}/$HOSTNAME

gen_csv() {
  file=$1
  outline=$2
  outdir=$3
  for i in $(seq 0 5)
  do
    jq ".tests[$i]" $file | ./json2csv.py -o ${outdir}/sec-$(($i+1)).csv - $outline
  done
}

# main program
mkdir -p ${CSVDir} || true
gen_csv $logfile csv-outline.json $CSVDir
