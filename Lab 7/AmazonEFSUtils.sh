#!/bin/bash

# Refresh local package repository
sudo yum update -y

# Configure cluster name using the template variable ${ecs_cluster_name}
# in order to use the EC2 Instances as part of the ECS Cluster after startup.
echo ECS_CLUSTER='${ecs_cluster_name}' | sudo tee -a /etc/ecs/ecs.config

# Install dependencies
sudo yum install -y git binutils
sudo yum install -y wget

# Install the appropriate version of the pip package manager based on Python version
if echo $(python3 -V 2>&1) | grep -e "Python 3.6"; then
    sudo wget https://bootstrap.pypa.io/pip/3.6/get-pip.py -O /tmp/get-pip.py
elif echo $(python3 -V 2>&1) | grep -e "Python 3.5"; then
    sudo wget https://bootstrap.pypa.io/pip/3.5/get-pip.py -O /tmp/get-pip.py
elif echo $(python3 -V 2>&1) | grep -e "Python 3.4"; then
    sudo wget https://bootstrap.pypa.io/pip/3.4/get-pip.py -O /tmp/get-pip.py
else
    # Install python3-distutils if Python version is not 3.4, 3.5, or 3.6
    sudo yum install -y python3-distutils
    sudo wget https://bootstrap.pypa.io/get-pip.py -O /tmp/get-pip.py
fi

# Install botocore using pip3
sudo python3 /tmp/get-pip.py
sudo pip3 install botocore

# Clone aws efs-utils repository
git clone https://github.com/aws/efs-utils

# Build the deb package
cd /efs-utils
sudo ./build-deb.sh

# Install the built deb package for amazon-efs-utils
sudo yum install -y ./build/amazon-efs-utils*deb

# Create a directory to mount efs
sudo mkdir /mnt/efs/
sudo mkdir /mnt/efs/fs1
