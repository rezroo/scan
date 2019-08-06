#!/bin/sh

logfile=docker-bench-security.sh
while getopts ":l:" opt; do
    case "${opt}" in
        l)
            logfile=${OPTARG}
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

if [ -z ${logfile+x} ]; then
   logfile=/results
   ./docker-bench-security.sh -l ${logfile} $@
else
   ./docker-bench-security.sh $@
fi
