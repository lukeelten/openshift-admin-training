#!/bin/bash
yum -y update
yum -y install centos-release-openshift-origin311 epel-release firewalld NetworkManager rng-tools bind-utils traceroute
yum -y install origin-clients nano docker
systemctl enable NetworkManager docker firewalld rngd
reboot