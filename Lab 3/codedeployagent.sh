#!/bin/bash

sudo apt update
sudo apt install -y ruby wget

aws_region='eu-west-2'

wget https://aws-codedeploy-${aws_region}.s3.${aws_region}.amazonaws.com/latest/install

chmod +x ./install
sudo ./install auto
sudo service codedeploy-agent start
echo "$(sudo service codedeploy-agent status)"
