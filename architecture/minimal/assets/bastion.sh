#!/bin/bash
yum -y update
yum -y install centos-release-openshift-origin311 epel-release NetworkManager firewalld
yum -y install origin-clients nfs-utils nano python2-passlib  httpd-tools patch java-1.8.0-openjdk-headless git gcc openssl-devel
yum -y install python36 python-passlib python36-tools python36-setuptools pyOpenSSL python-cryptography python-lxml python36-setuptools python36-devel python36-pip ansible
easy_install-3.6 pip
systemctl enable firewalld NetworkManager
systemctl disable iptables iptables6
sudo -u centos -i git clone https://github.com/openshift/openshift-ansible.git
reboot