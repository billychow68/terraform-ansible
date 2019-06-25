terraform {
  required_version = ">= 0.12.0"
}
provider "aws" {
  profile = "default"
  region  = "${var.region}"
}
# ---------------------------------------------------------------------------------------------------------------------
# S3 Bucket
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_s3_bucket" "bucket1" {
  bucket = "billychow68-bucket1"
  acl    = "private"
  tags = {
    Name = "billychow68-bucket1"
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# resource: elb
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_elb" "example" {
  name               = "terraform-asg-example"
  availability_zones = ["us-east-1a"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:${var.server_port}/"
    interval            = 30
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# resource: security group for elastic_load_balancer
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "elb" {
  name = "terraform-example-elb"

  # for inbound requests on port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # for health check
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "training elb"
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# resource: autoscaling group
# ---------------------------------------------------------------------------------------------------------------------
#data "aws_availability_zones" "all" {}
resource "aws_autoscaling_group" "example" {
  launch_configuration = "${aws_launch_configuration.ubuntu.id}"
  # availability_zones = ["${data.aws_availability_zones.all.names}"]
  #availability_zones = ["us-east-1a","us-east-1b","us-east-1c"]
  availability_zones = ["us-east-1a"]

  load_balancers    = ["${aws_elb.example.name}"]
  health_check_type = "ELB"

  min_size = "${var.min_size}"
  max_size = "${var.max_size}"

  tag {
    key                 = "Name"
    value               = "terraform_asg_example"
    propagate_at_launch = true
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# AWS launch configuration
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_launch_configuration" "ubuntu" {
  image_id      = var.amis[var.region]
  instance_type = "t2.micro"
  key_name      = "ec2-key-pair"
  # tags = {
  #   Name = "instance1"
  # }
  # use busybox to serve up hello world
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  security_groups = ["${aws_security_group.training-app.name}"]
  #vpc_security_group_ids = ["${aws_security_group.training.id}"]
  # explicit dependency
  depends_on = [aws_s3_bucket.bucket1]
  lifecycle {
    create_before_destroy = true
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# resource: security group for EC2 instances
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_security_group" "training-app" {
  name = "training-app"
  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "${var.server_port}"
    to_port = "${var.server_port}"
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "training-app"
  }
  lifecycle {
    create_before_destroy = true
  }
}
# ---------------------------------------------------------------------------------------------------------------------
# outputs
# ---------------------------------------------------------------------------------------------------------------------
# output "eip1" {
#   value = aws_eip.eip1.public_ip
# }
# output "eip2" {
#   value = aws_eip.eip2.public_ip
# }
# output "s3_bucket" {
#   value = aws_s3_bucket.bucket1.tags.Name
# }
# output "elb_dns_name" {
#   value = "${aws_elb.example.dns_name}"
# }
# output "security_group" {
#   value = aws_security_group.training.tags.Name
# }
