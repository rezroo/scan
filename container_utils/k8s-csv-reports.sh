#!/usr/bin/env bash

# Sample jq commands to get partial data out:
# jq ".results" auk57r03o001-k8s-worker-13.json
# jq ".profile" auk57r03o001-k8s-worker-13.json
# jq ".rules" auk57r03o001-k8s-worker-13.json
# jq ".rules[].id" auk57r03o001-k8s-worker-13.json
# jq ".profiles" auk57r03o001-k8s-worker-13.json

gencsv()
{
    script=$1
    input=$2
    python ${script}/json2csv.py -o ${input}-1.csv ${input}.json ${script}/outline.result.txt
    python ${script}/json2csv.py -o ${input}-2.csv ${input}.json ${script}/outline.rule.txt
}

gencsv ~/NC-June24/JSON/json2csv ~/NC-June24/2019-6-20/json/auk57r03o001-k8s-worker-13
gencsv ~/NC-June24/JSON/json2csv ~/NC-June24/2019-6-20/json/auk57r03o001-k8s-master-13
