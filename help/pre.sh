#!/bin/bash

# echo "127.0.0.1 airtime" >> /etc/hosts

export DEBIAN_FRONTEND=noninteractive

locale-gen --purge en_US.UTF-8 && echo -e 'LANG="$LANG"\nLANGUAGE="$LANGUAGE"\n' > /etc/default/locale

echo "airtime   ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers
adduser --disabled-password --gecos "" airtime
adduser --disabled-password --gecos "" icecast2

apt-get update
apt-get install -y rabbitmq-server apache2 curl supervisor postgresql unzip sudo


pg_dropcluster 9.3 main
pg_createcluster --locale en_US.UTF-8 9.3 main
echo "host    all             all             0.0.0.0/0 trust" >> /etc/postgresql/9.5/main/pg_hba.conf
echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf
