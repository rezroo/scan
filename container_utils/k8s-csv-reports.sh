#!/usr/bin/env bash

if [ -z "$1" ]; then
   logfile=/scan/results/k8s/${HOSTNAME}.json
else
   logfile=${1}
fi

CSV_DIR=$(dirname $logfile)/k8s_csv

if [ ! -d ${CSV_DIR} ]; then
  mkdir -p $CSV_DIR
fi

# Sample jq commands to get partial data out:
# jq ".results" hostname-k8s-worker-13.json
# jq ".profile" hostname-k8s-worker-13.json
# jq ".rules" hostname-k8s-worker-13.json
# jq ".rules[].id" hostname--k8s-worker-13.json
# jq ".profiles" hostname-k8s-worker-13.json

gencsv()
{
    log_json=$1
    python ./json2csv.py -o ${CSV_DIR}/scan-1.csv $log_json ./k8s-outline.result.txt
    python ./json2csv.py -o ${CSV_DIR}/scan-2.csv $log_json ./k8s-outline.rule.txt
}

gencsv $logfile
