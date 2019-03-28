#!/bin/bash
yum -y update
yum -y install centos-release-openshift-origin311 epel-release firewalld NetworkManager haveged
yum -y install origin-clients nano docker
systemctl enable NetworkManager docker firewalld haveged
systemctl disable iptables iptables6
reboot