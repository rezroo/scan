CWD=/scan/results
cd /scan/jsondiff
ScanDir1=${1}
ScanDir2=${2}
ScanFile=${3}.log.json
#set -x
echo "\["
echo "\"" "python -m jsondiff.cli ${ScanDir1}/${ScanFile} ${ScanDir2}/${ScanFile}" "\","
python -m jsondiff.cli ${ScanDir1}/${ScanFile} ${ScanDir2}/${ScanFile} | jq '.'
echo "\,"
echo "\"" "python -m jsondiff.cli ${ScanDir2}/${ScanFile} ${ScanDir1}/${ScanFile}" "\","
python -m jsondiff.cli ${ScanDir2}/${ScanFile} ${ScanDir1}/${ScanFile} | jq '.'
echo "\]"
