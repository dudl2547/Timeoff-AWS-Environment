#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user
sudo curl -O https://releases.hashicorp.com/terraform/0.11.5/terraform_0.11.5_linux_amd64.zip 
sudo unzip terraform_0.11.5_linux_amd64.zip -d /usr/bin/ 
terraform --version
sudo yum install git -y
sudo git clone https://github.com/dudl2547/Timeoff.git
cd Timeoff
sudo terraform init
sudo terraform plan
sudo terraform apply -auto-approve
