#!/bin/bash

yum -y update
yum -y install epel-release NetworkManager nfs-utils
yum -y install rng-tools nano git bind-utils traceroute targetcli iscsi-initiator-utils
systemctl enable rngd NetworkManager nfs-server target

# systemctl enable firewalld
# systemctl start firewalld

#sleep 2
#firewall-cmd --permanent --zone=public --add-service=nfs
#firewall-cmd --permanent --zone=public --add-service=mountd
#firewall-cmd --permanent --zone=public --add-service=rpc-bind
#firewall-cmd --permanent --add-port=3260/tcp
#firewall-cmd --reload

mkdir /export

EXPORTS=$(cat <<EOF
/export     *(rw,sync,no_root_squash,no_all_squash)
EOF
)
echo "$EXPORTS" >> /etc/exports

reboot