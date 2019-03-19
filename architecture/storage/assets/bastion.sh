#!/bin/bash
yum -y update
yum -y install centos-release-openshift-origin311 epel-release NetworkManager firewalld
yum -y install origin-clients nfs-utils python36 python36-tools nano python-passlib python2-passlib ansible python36-pip httpd-tools patch java-1.8.0-openjdk-headless git pyOpenSSL python-cryptography python-lxml
systemctl enable firewalld NetworkManager
systemctl disable iptables iptables6
sudo -u centos -i git clone https://github.com/openshift/openshift-ansible.git
reboot