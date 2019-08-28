CWD=/scan/results
cd /scan/jsondiff
# /scan/results/docker/$HOSTNAME.log
ScanDir1=$(dirname ${1})

# /scan/results/host
ScanDir2=${2}
ScanFile=$(basename -s .log -s .xml -s .json ${1}).json
#set -x
echo "["
echo "\"" "python -m jsondiff.cli ${ScanDir1}/${ScanFile} ${ScanDir2}/${ScanFile}" "\","
python -m jsondiff.cli ${ScanDir1}/${ScanFile} ${ScanDir2}/${ScanFile} | jq '.'
echo ","
echo "\"" "python -m jsondiff.cli ${ScanDir2}/${ScanFile} ${ScanDir1}/${ScanFile}" "\","
python -m jsondiff.cli ${ScanDir2}/${ScanFile} ${ScanDir1}/${ScanFile} | jq '.'
echo "]"
