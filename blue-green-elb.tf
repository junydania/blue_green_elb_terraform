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

resource "aws_lb" "blue_green_elb" {
  name                = "blue-green-elb"
  internal            = false
  load_balancer_type  = "application"

  idle_timeout                = 400

  tags {
    Name = "blue-green-elb"
  }
}

resource "aws_vpc" "blue_green_vpc" {
  cidr_block = "10.0.0.0/16"

  tags {
    Name = "blue-green-vpc"
  }
}

resource "aws_lb_target_group" "blue_elb_target_group" {
  name        = "blue_ec2_elb_target_group"
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
  name        = "green_ec2_elb_target_group"
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