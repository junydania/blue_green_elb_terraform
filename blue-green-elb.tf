# This terraform file is an attempt to provision AWS resources to create an ELB
# with listener groups pointing to 2 separate EC2 instances. The goal is to
# create a script that can provision infrastructure that supports a blue-green
# deployment approach in an automated fashion.
#
# These blog posts were very helpful:
# http://blog.kaliloudiaby.com/index.php/terraform-to-provision-vpc-on-aws-amazon-web-services/
# https://www.bogotobogo.com/DevOps/DevOps-Terraform.php

provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "auth" {
  key_name   = "${var.key_name}"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "blue_ec2" {
  connection {
    user = "ubuntu"
  }

  ami             = "ami-059eeca93cf09eebd" # Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
  instance_type   = "t2.micro"
  subnet_id       = "${aws_subnet.blue_subnet.id}"
  security_groups = ["${aws_security_group.blue_green_instance_security_group.id}"]
  key_name        = "${aws_key_pair.auth.id}"

  # Install Nginx immediately
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "systemctl start nginx.service",
    ]
  }

  tags {
    Name = "blue_ec2"
  }
}

resource "aws_instance" "green_ec2" {
  connection {
    user = "ubuntu"
  }

  ami             = "ami-059eeca93cf09eebd" # Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
  instance_type   = "t2.micro"
  subnet_id       = "${aws_subnet.green_subnet.id}"
  security_groups = ["${aws_security_group.blue_green_instance_security_group.id}"]
  key_name        = "${aws_key_pair.auth.id}"

  # Install Nginx immediately
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "systemctl start nginx.service",
    ]
  }

  tags {
    Name = "green_ec2"
  }
}

resource "aws_lb" "blue_green_elb" {
  name                = "blue-green-elb"
  internal            = false
  load_balancer_type  = "application"
  security_groups     = ["${aws_security_group.blue_green_elb_security_group.id}"]
  subnets             = ["${aws_subnet.green_subnet.id}", "${aws_subnet.blue_subnet.id}"]

  idle_timeout        = 400

  tags {
    Name = "blue-green-elb"
  }
}

resource "aws_vpc" "blue_green_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name = "blue-green-vpc"
  }
}

resource "aws_internet_gateway" "blue_green_internet_gateway" {
  vpc_id = "${aws_vpc.blue_green_vpc.id}"

  tags {
    Name = "blue-green-internet-gateway"
  }
}

resource "aws_route" "blue_green_internet_access_route" {
  route_table_id         = "${aws_vpc.blue_green_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.blue_green_internet_gateway.id}"
}

# Provides security group configuration for the ELB itself (eg. internet access)
resource "aws_security_group" "blue_green_elb_security_group" {
  name        = "blue_green_elb_security_group"
  vpc_id      = "${aws_vpc.blue_green_vpc.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Provides security group configuration for EC2 instances (eg. SSH and HTTP)
resource "aws_security_group" "blue_green_instance_security_group" {
  name        = "blue_green_instance_security_group"
  vpc_id      = "${aws_vpc.blue_green_vpc.id}"

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # Outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "blue_elb_target_group" {
  name        = "blue-ec2-elb-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "${aws_vpc.blue_green_vpc.id}"

  tags {
    Name = "blue-elb-target-group"
  }
}

resource "aws_lb_target_group_attachment" "blue_elb_target_group_attachment" {
  target_group_arn = "${aws_lb_target_group.blue_elb_target_group.arn}"
  target_id        = "${aws_instance.blue_ec2.id}"
  port             = 80
}

resource "aws_lb_target_group" "green_elb_target_group" {
  name        = "green-ec2-elb-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = "${aws_vpc.blue_green_vpc.id}"

  tags {
    Name = "green-elb-target-group"
  }
}

resource "aws_lb_target_group_attachment" "green_elb_target_group_attachment" {
  target_group_arn = "${aws_lb_target_group.green_elb_target_group.arn}"
  target_id        = "${aws_instance.green_ec2.id}"
  port             = 80
}

resource "aws_lb_listener" "blue_green_elb_listener" {
  "default_action" {
    type = "forward"
    target_group_arn = "${aws_lb_target_group.green_elb_target_group.arn}"
  }

  load_balancer_arn = "${aws_lb.blue_green_elb.arn}"
  port              = 80
  protocol          = "HTTP"
}

resource "aws_subnet" "blue_subnet" {
  availability_zone       = "us-east-1a"
  vpc_id                  = "${aws_vpc.blue_green_vpc.id}"
  cidr_block              = "10.0.1.0/24"

  # Make sure EC2 instances added to this subnet get public IP addresses
  map_public_ip_on_launch = true

  tags {
    Name = "blue_subnet"
  }
}

resource "aws_subnet" "green_subnet" {
  availability_zone       = "us-east-1b"
  vpc_id                  = "${aws_vpc.blue_green_vpc.id}"
  cidr_block              = "10.0.2.0/24"

  # Make sure EC2 instances added to this subnet get public IP addresses
  map_public_ip_on_launch = true

  tags {
    Name = "green_subnet"
  }
}
