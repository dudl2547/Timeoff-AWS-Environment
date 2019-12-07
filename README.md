# Timeoff-AWS-Environment
AWS Cloud Infrastructure to Deploy Timeoff-Management
Terraform is required to be installed and configured on your device
This was tested with Version 0.11.5

1.To create the AWS environment, clone the Timeoff-AWS-Environment Repo
git clone https://github.com/dudl2547/Timeoff-AWS-Environment.git
cd Timeoff-AWS-Environment

2. Modify the terraform.tfvars file with your AWS access and secret keys

3. Create the terraform environment

(Note - At this point in time, the container will not launch unless you SSH into the device first
You may need to manually create an instance and login to the instance
(Userdata script in userdata.sh))
