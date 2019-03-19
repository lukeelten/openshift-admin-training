#!/bin/bash
yum -y update
yum -y install centos-release-openshift-origin311 epel-release firewalld NetworkManager
yum -y install origin-clients nfs-utils python36 python36-tools nano python-passlib python2-passlib docker
systemctl enable NetworkManager docker firewalld
systemctl disable iptables iptables6
reboot