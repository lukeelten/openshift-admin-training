#!/bin/bash

yum -y update
yum -y install epel-release NetworkManager firewalld nfs-utils
yum -y install docker rng-tools nano git bind-utils traceroute
systemctl enable docker rngd NetworkManager firewalld
systemctl start firewalld

#firewall-cmd --permanent --zone=public --add-service=nfs
#firewall-cmd --permanent --zone=public --add-service=mountd
#firewall-cmd --permanent --zone=public --add-service=rpc-bind
#firewall-cmd --reload
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

NEXUS=$(cat <<EOF
version: '3.5'

volumes:
  nexus:
    driver: local
  mariadb:
    driver: local

networks:
  keycloak:
    driver: bridge

services:
  nexus:
    restart: always
    image: sonatype/nexus3
    expose:
      - "8081"
      - "5000-5050"
    ports:
      - "8080:8081"
      - "5000-5050:5000-5050"
    volumes:
      - nexus:/nexus-data
    networks:
      - keycloak

  ldap:
    restart: always
    image: osixia/openldap
    environment:
      LDAP_ORGANISATION: "codecentric AG"
      LDAP_DOMAIN: "cc-openshift.de"
      LDAP_BASE_DN: ""
      LDAP_ADMIN_PASSWORD: "tayfFhxyVjrVwjlKNfIEsRZq4"
      LDAP_READONLY_USER: "true"
      LDAP_READONLY_USER_USERNAME: "openshift"
      LDAP_READONLY_USER_PASSWORD: "OpenShiftLdap"
    ports:
      - 389:389
      - 636:636
    networks:
      - keycloak

  keycloak:
    restart: always
    image: quay.io/keycloak/keycloak:6.0.1
    environment:
      DB_VENDOR: MARIADB
      DB_ADDR: mariadb
      DB_DATABASE: keycloak
      DB_USER: keycloak
      DB_PASSWORD: 2jyG7e2dZ3e4QZxC
      KEYCLOAK_USER: admin
      KEYCLOAK_PASSWORD: password
      KEYCLOAK_HOSTNAME: sso.cc-openshift.de
    ports:
      - 80:8080
      - 443:8443
    depends_on:
      - mariadb
    networks:
      - keycloak

  mariadb:
    restart: always
    image: mariadb:10.3
    expose:
    - 3306
    volumes:
    - mariadb:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: 2jyG7e2dZ3e4QZxC
      MYSQL_DATABASE: keycloak
      MYSQL_USER: keycloak
      MYSQL_PASSWORD: 2jyG7e2dZ3e4QZxC
    networks:
    - keycloak
EOF
)

echo "$NEXUS" > /home/centos/nexus.yml
gpasswd -a centos docker
chown centos:centos /home/centos/nexus.yml


reboot