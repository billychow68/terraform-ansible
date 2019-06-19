terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

# S3 resource: EXAMPLE
resource "aws_s3_bucket" "example" {
  bucket  = "billychow68-example"
  acl     = "private"
}

# EC2 resource: EXAMPLE
resource "aws_instance" "example" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"

  # explicit depends on S3 bucket
  depends_on    = [aws_s3_bucket.example]
}
resource "aws_eip" "ip" {
  # implicit dependency on EIP
  instance = aws_instance.example.id
}

# EC2 resource: ANOTHER
resource "aws_instance" "another" {
  ami           = "ami-b374d5a5"
  instance_type = "t2.micro"
}
