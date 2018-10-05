provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "blue_ec2" {
  ami           = "ami-059eeca93cf09eebd" # Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"

  tags {
    Name = "blue_ec2"
  }
}

resource "aws_instance" "green_ec2" {
  ami           = "ami-059eeca93cf09eebd" # Ubuntu Server 16.04 LTS (HVM), SSD Volume Type
  instance_type = "t2.micro"

  tags {
    Name = "green_ec2"
  }
}

resource "aws_elb" "blue_green_elb" {
  name                = "blue-green-elb"
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]

  "listener" {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  instances                   = ["${aws_instance.green_ec2.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400

  tags {
    Name = "blue-green-elb"
  }
}