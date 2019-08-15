#/bin/sh
set -ex
if [ -z "$1" ]; then
    XMLDIR=/scan/results/k8s
else
    XMLDIR=$(realpath $1)
fi

for f in $XMLDIR/*.xml; do
    python -m xmlutils/console --input $f --pretty
done
