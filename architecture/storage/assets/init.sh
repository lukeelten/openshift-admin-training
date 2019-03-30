#!/bin/bash
yum -y update
yum -y install centos-release-openshift-origin311 epel-release firewalld NetworkManager haveged bind-utils traceroute
yum -y install origin-clients nano docker
systemctl enable NetworkManager docker firewalld haveged
reboot