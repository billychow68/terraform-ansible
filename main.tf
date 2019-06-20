terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
#####################################################################
# S3 Bucket
#####################################################################
resource "aws_s3_bucket" "bucket1" {
  bucket  = "billychow68-bucket1"
  acl     = "private"
  tags = {
    Name = "billychow68-bucket1"
  }
}
#####################################################################
# EC2 resource: instance1
#####################################################################
resource "aws_instance" "instance1" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"
  key_name      = "ec2-key-pair"
  tags = {
    Name = "instance1"
  }
  security_groups  = ["${aws_security_group.training.name}"]
  # explicit dependency
  depends_on    = [aws_s3_bucket.bucket1]
}
resource "aws_eip" "eip1" {
  # implicit dependency on EIP
  instance = aws_instance.instance1.id
  provisioner "local-exec" {
    command = "echo ${aws_eip.eip1.tags.Name} ${aws_eip.eip1.public_ip} >> ip_address.txt"
  }
  tags = {
    Name = "eip1"
  }
}

#####################################################################
# EC2 resource: instance2
#####################################################################
resource "aws_instance" "instance2" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"
  key_name      = "ec2-key-pair"
  tags = {
    Name = "instance2"
  }
  security_groups  = ["${aws_security_group.training.name}"]
}
resource "aws_eip" "eip2" {
  # implicit dependency on EIP
  instance = aws_instance.instance2.id
  provisioner "local-exec" {
    command = "echo ${aws_eip.eip2.tags.Name} ${aws_eip.eip2.public_ip} >> ip_address.txt"
  }
  tags = {
    Name = "eip2"
  }
}

#####################################################################
# resource: security group
#####################################################################
resource "aws_security_group" "training" {
  name        = "training"
  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  tags = {
    Name = "training"
  }
}
