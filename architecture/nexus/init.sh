#!/bin/bash

yum -y update
yum -y install epel-release
yum -y install docker
systemctl enable docker
systemctl start docker

curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

echo <<EOF
version: '3'

volumes:
  nexus:
    driver: local

services:
  nexus:
    restart: always
    image: sonatype/nexus3
    expose:
      - 8081
      - "5000-5010"
    ports:
      - 80:8081
      - "5000-5010"
    volumes:
      - nexus:/nexus-data
EOF > /nexus.yml
docker-compose -f /nexus.yml -p nexus up -d


reboot