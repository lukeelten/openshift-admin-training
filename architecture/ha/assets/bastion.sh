#!/bin/bash
yum -y update
yum -y install centos-release-openshift-origin311 epel-release NetworkManager firewalld rng-tools bind-utils traceroute
yum -y install origin-clients nano python2-passlib httpd-tools patch java-1.8.0-openjdk-headless git gcc openssl-devel
yum -y install python-passlib pyOpenSSL python-cryptography python-lxml ansible python2-pip python-devel
systemctl enable firewalld NetworkManager rngd
sudo -u centos -i git clone https://github.com/openshift/openshift-ansible.git
reboot