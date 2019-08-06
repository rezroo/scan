#!/bin/sh
set -x

# This works
oscap info mirantis/xccdf/cis_kubernetes_benchmark/1.3.0/cis_kubernetes_benchmark-xccdf-ds.xml
oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results test.xml --report test.html --profile xccdf_com.mirantis_profile_worker mirantis/xccdf/cis_kubernetes_benchmark/1.3.0/cis_kubernetes_benchmark-xccdf.xml
# This doesn't works
oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results test.xml --report test.html --profile xccdf_com.mirantis_profile_worker mirantis/xccdf/cis_kubernetes_benchmark/1.3.0/cis_kubernetes_benchmark-xccdf-ds.xml



#oscap info /usr/share/openscap/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf-ds.xml

# This works
oscap info mirantis/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf-ds.xml
oscap xccdf eval --skip-valid --progress   --results results/results.xml --report results/report.html   --profile xccdf_com.mirantis_profile_default /usr/share/openscap/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf-ds.xml

# oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results test.xml --report test.html --profile xccdf_com.mirantis_profile_default mirantis/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf.xml

#root@auk57r03o001:~/scap-content# oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results test.xml --report test.html --profile xccdf_com.mirantis_profile_default mirantis/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf.xml

# oscap xccdf eval --cpe mirantis/cpe/openscap-cpe-dict.xml --results test.xml --report test.html --profile xccdf_com.mirantis_profile_default mirantis/xccdf/cis_ubuntu_1604_server_l2/1.0.0/cis_ubuntu_1604_server_l2-xccdf.xml

sleep 3600
