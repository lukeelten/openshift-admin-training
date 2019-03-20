#!/bin/bash
yum -y update
yum -y install centos-release-openshift-origin310 epel-release firewalld NetworkManager
yum -y install origin-clients nfs-utils nano docker
systemctl enable NetworkManager docker firewalld
systemctl disable iptables iptables6
reboot