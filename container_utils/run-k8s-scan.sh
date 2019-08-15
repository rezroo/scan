#!/bin/sh
set -x
if [ -z "$1" ]; then
   ResDir=/scan/results/k8s
else
   ResDir=$1
fi
mkdir -p $ResDir || true
ResXML=$ResDir/${HOSTNAME}.xml
ResHTML=$ResDir/${HOSTNAME}.html

# Figure out which profile to use:
if echo $HOSTNAME | grep -Eq 'auk[0-9][0-9]r[0-9][0-9]o'; then
  TARGET="master"
elif echo $HOSTNAME | grep -Eq 'auk[0-9][0-9]r[0-9][0-9]c'; then
  TARGET="worker"
else
  # Assume we are running tests on all-in-one clusters
  TARGET="master"
fi
PROFILE=$(oscap info mirantis/xccdf/cis_kubernetes_benchmark/1.3.0/cis_kubernetes_benchmark-xccdf-ds.xml | grep xccdf_com.mirantis_profile_$TARGET)

oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results $ResXML --report $ResHTML --profile $PROFILE \
      mirantis/xccdf/cis_kubernetes_benchmark/1.3.0/cis_kubernetes_benchmark-xccdf.xml


# This doesn't works
#oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results test.xml --report test.html --profile xccdf_com.mirantis_profile_worker mirantis/xccdf/cis_kubernetes_benchmark/1.3.0/cis_kubernetes_benchmark-xccdf-ds.xml



#oscap info /usr/share/openscap/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf-ds.xml

# This works
#oscap info mirantis/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf-ds.xml
#oscap xccdf eval --skip-valid --progress   --results results/results.xml --report results/report.html   --profile xccdf_com.mirantis_profile_default /usr/share/openscap/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf-ds.xml

# oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results test.xml --report test.html --profile xccdf_com.mirantis_profile_default mirantis/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf.xml

#root@auk57r03o001:~/scap-content# oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results test.xml --report test.html --profile xccdf_com.mirantis_profile_default mirantis/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf.xml

# oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results test.xml --report test.html --profile xccdf_com.mirantis_profile_default mirantis/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf.xml

#sleep 3600
