#!/bin/bash

# Update System
yum -y update

# Install dependencies
yum -y install centos-release-openshift-origin311 epel-release NetworkManager firewalld rng-tools bind-utils traceroute
yum -y install origin-clients nano httpd-tools patch java-1.8.0-openjdk-headless git gcc openssl-devel docker

# Python 2
#yum install -y python2-passlib python-passlib pyOpenSSL python-cryptography python-lxml python2-pip python-devel

# Python 3
yum install -y python3-pip

yum -y upgrade epel-release
yum -y update

# Enable services
systemctl enable firewalld NetworkManager rngd docker
gpasswd -a centos root

# DOwnload Training Content
sudo -u centos -i git clone https://github.com/openshift/openshift-ansible.git
sudo -u centos -i git clone https://github.com/lukeelten/openshift-admin-training.git workshop

# Download OpenShift 4 Installer
sudo -u centos -i mkdir openshift4
sudo -u centos -i curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-install-linux.tar.gz -o openshift4/install.tar.gz
sudo -u centos -i tar -C openshift4 -xvf openshift4/install.tar.gz

# Download OpenShift 4 CLI
sudo -u centos -i curl https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz -o openshift4/client.tar.gz
sudo -u centos -i tar -C openshift4 -xvf openshift4/client.tar.gz

# Cleanup
sudo -u centos -i rm -f openshift4/*.tar.gz  openshift4/*.md

reboot