provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "timeoff_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "timeoff_vpc"
  }
}

resource "aws_internet_gateway" "timeoff_internet_gateway" {
  vpc_id = "${aws_vpc.timeoff_vpc.id}"

  tags {
    Name = "timeoff_igw"
  }
}

resource "aws_route_table" "timeoff_public_rt" {
  vpc_id = "${aws_vpc.timeoff_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.timeoff_internet_gateway.id}"
  }

  tags {
    Name = "timeoff_public"
  }
}

resource "aws_default_route_table" "timeoff_private_rt" {
  default_route_table_id = "${aws_vpc.timeoff_vpc.default_route_table_id}"

  tags {
    Name = "timeoff_private"
  }
}

resource "aws_subnet" "timeoff_public_subnet" {
  vpc_id                  = "${aws_vpc.timeoff_vpc.id}"
  cidr_block              = "${var.subnet_cidr}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags {
    Name = "timeoff_public_subnet"
  }
}

resource "aws_route_table_association" "timeoff_public_assoc" {
  subnet_id      = "${aws_subnet.timeoff_public_subnet.id}"
  route_table_id = "${aws_route_table.timeoff_public_rt.id}"
}

resource "aws_security_group" "timeoff_public_sg" {
  name        = "timeoff_public_sg"
  description = "Used to allow traffic"
  vpc_id      = "${aws_vpc.timeoff_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outbound internet access

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "timeoff_auth" {
  key_name   = "${var.key_name}"
  public_key = "${tls_private_key.example.public_key_openssh}"
}

resource "aws_instance" "timeoff_dev" {
  instance_type = "${var.instance_type}"
  ami           = "${var.ami}"

  tags {
    Name = "timeoff_serv"
  }

  key_name               = "${aws_key_pair.timeoff_auth.key_name}"
  vpc_security_group_ids = ["${aws_security_group.timeoff_public_sg.id}"]

  #iam_instance_profile   = "${aws_iam_instance_profile.s3_access_profile.id}"
  subnet_id = "${aws_subnet.timeoff_public_subnet.id}"

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              sudo curl -O https://releases.hashicorp.com/terraform/0.11.5/terraform_0.11.5_linux_amd64.zip
              sudo unzip terraform_0.11.5_linux_amd64.zip -d /usr/local/bin/ 
              terraform --version
	            sudo yum install git -y
              sudo git clone https://github.com/dudl2547/Timeoff.git
              cd Timeoff
	            sudo docker ps -a
              sudo terraform init
              sudo terraform plan
              sudo terraform apply -auto-approve
              sudo docker ps -a
              EOF
}
