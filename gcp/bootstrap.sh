#!/bin/bash
#

PROJECT="fluted-castle-171309"
ZONE="us-central1-c"
SUBNET="default"
LOGIN_NAME="davidchang"
PUBLIC_IP="35.184.61.43"
MASTER0_IP="35.184.61.44"

# Install 

sudo yum update google-cloud-sdk &&
sudo yum update &&
sudo yum install -y epel-release &&
sudo yum install -y python-pip &&
sudo pip install -U pip &&
sudo pip install 'apache-libcloud==1.2.1' &&
sudo pip install 'docker-py==1.9.0' &&
sudo yum install -y git ansible

# Install docker

sudo setenforce 0 && sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config

sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
&&
sudo yum install -y docker-engine-1.11.2

sudo sed -i 's/ExecStart=\/usr\/bin\/docker daemon -H fd:\/\//ExecStart=\/usr\/bin\/docker daemon --storage-driver=overlay/g' /usr/lib/systemd/system/docker.service

sudo systemctl daemon-reload

sudo systemctl start docker.service

# Install DC/OS GCE scripts

git clone https://github.com/dcos-labs/dcos-gce &&

cd dcos-gce

sudo sed -i "s/project.*/project: "${PROJECT}"/g" group_vars/all &&
sudo sed -i "s/subnet.*/subnet: "${SUBNET}"/g" group_vars/all &&
sudo sed -i "s/login_name.*/login_name: "${LOGIN_NAME}"/g" group_vars/all &&
sudo sed -i "s/bootstrap_public_ip.*/bootstrap_public_ip: "${PUBLIC_IP}"/g" group_vars/all &&
sudo sed -i "s/zone.*/zone: "${ZONE}"/g" group_vars/all 


tee ~/.ansiblei.cfg <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/7/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
&&
ansible-playbook -i hosts install.yml

