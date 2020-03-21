#!/bin/bash

yum -y update
yum -y install epel-release NetworkManager nfs-utils
yum -y install docker rng-tools nano git bind-utils traceroute nginx python2-certbot-nginx
systemctl enable docker rngd NetworkManager nginx


#
#mkdir /export
#
#EXPORTS=$(cat <<EOF
#/export     *.*.*.*(rw,sync,no_root_squash,no_all_squash)
#EOF
#)
#echo "$EXPORTS" >> /etc/exports


curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

gpasswd -a centos docker
gpasswd -a centos root

semanage port -m -p tcp -t http_port_t 8080


reboot