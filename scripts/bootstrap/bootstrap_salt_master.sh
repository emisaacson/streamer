#!/bin/bash

#echo 'deb http://debian.saltstack.com/debian wheezy-saltstack main' > /etc/apt/sources.list.d/salt.list
#wget -q -O- "http://debian.saltstack.com/debian-salt-team-joehealy.gpg.key" | apt-key add -

fallocate -l 769M /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo "/swapfile               none    swap    defaults        0 0" >> /etc/fstab

apt-get update
apt-get -y upgrade

apt-get -y install curl
mkdir /opt/salt
pushd /opt/salt
curl -o install_salt.sh -L https://bootstrap.saltstack.com
bash install_salt.sh -M -N git v2015.5
popd

apt-get -y install python-pip
apt-get -y install python-dev
pip install apache-libcloud

pip install awscli

apt-get -y install openjdk-7-jre
wget -O /root/ec2-api-tools.zip http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip

pip install pyzmq PyYAML pycrypto msgpack-python jinja2 psutil
pip install jinja2-cli 

apt-get -y install unzip
unzip /root/ec2-api-tools.zip -d /usr/local/
mv /usr/local/ec2-* /usr/local/ec2

echo 'export EC2_HOME="/usr/local/ec2"' > /etc/profile.d/ec2.sh
echo 'export PATH="$PATH:$EC2_HOME/bin"' >> /etc/profile.d/ec2.sh
echo 'export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64/jre"' > /etc/profile.d/java.sh

export EC2_HOME="/usr/local/ec2"
export PATH="$PATH:$EC2_HOME/bin"
export JAVA_HOME="/usr/lib/jvm/java-7-openjdk-amd64/jre"

ln -s /opt/stack/templates/salt/states /srv/salt

ln -s /opt/stack/templates/salt/pillar /srv/pillar

NGINX_VERSION=1.6.0
wget -q -O- http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz > /srv/salt/nginx.tar.gz

ln -s /opt/stack/scripts/install/nginx-media-server.sh /srv/salt/nginx-media-server.sh

cp -f /opt/stack/templates/salt/master /etc/salt/master
service salt-master restart

if [ x"$1" != "x" ]:
	echo "$1" > /etc/salt/KEYPAIR.pem
	chmod 400 /etc/salt/KEYPAIR.pem
	bash /opt/stack/scripts/bootstrap/bootstrap_salt_stack.sh "$2" "$3"
fi
