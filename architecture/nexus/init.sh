#!/bin/bash

yum -y update
yum -y install epel-release NetworkManager
yum -y install docker haveged nano git bind-utils traceroute
systemctl enable docker haveged NetworkManager
systemctl start docker haveged NetworkManager

curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

NEXUS=$(cat <<EOF
version: '3'

volumes:
  nexus:
    driver: local

services:
  nexus:
    restart: always
    image: sonatype/nexus3
    expose:
      - "8081"
      - "5000-5010"
    ports:
      - "80:8081"
      - "5000-5010:5000-5010"
    volumes:
      - nexus:/nexus-data
EOF
)
echo "$NEXUS" > /nexus.yml
docker-compose -f /nexus.yml -p nexus up -d


reboot