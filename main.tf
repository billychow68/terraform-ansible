terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# S3 resource: EXAMPLE
resource "aws_s3_bucket" "bucket1" {
  bucket  = "billychow68-bucket1"
  acl     = "private"
  tags = {
    Name = "billychow68-bucket1"
  }
}

# EC2 resource: instance1
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
  provisioner "local-exec" {
    command = "echo ${aws_instance.instance1.public_ip} >> ip_address.txt"
  }
}
resource "aws_eip" "eip1" {
  # implicit dependency on EIP
  instance = aws_instance.instance1.id
  tags = {
    Name = "eip1"
  }
}

# EC2 resource: instance2
resource "aws_instance" "instance2" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"
  key_name      = "ec2-key-pair"
  tags = {
    Name = "instance2"
  }
  security_groups  = ["${aws_security_group.training.name}"]
  provisioner "local-exec" {
    command = "echo ${aws_instance.instance2.public_ip} >> ip_address.txt"
  }
}
resource "aws_eip" "eip2" {
  # implicit dependency on EIP
  instance = aws_instance.instance2.id
  tags = {
    Name = "eip2"
  }
}

# resource: security group
resource "aws_security_group" "training" {
  name        = "training"

  ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "ssh"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}
