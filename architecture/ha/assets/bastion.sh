#!/bin/bash
yum -y update
yum -y install centos-release-openshift-origin311 epel-release NetworkManager firewalld haveged
yum -y install origin-clients nfs-utils nano python2-passlib  httpd-tools patch java-1.8.0-openjdk-headless git gcc openssl-devel
yum -y install python-passlib pyOpenSSL python-cryptography python-lxml ansible python2-pip python-devel
systemctl enable firewalld NetworkManager haveged
systemctl disable iptables iptables6
sudo -u centos -i git clone https://github.com/openshift/openshift-ansible.git
reboot