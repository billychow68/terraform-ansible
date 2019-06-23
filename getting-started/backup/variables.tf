
variable "region" {
  default = "us-east-1"
}

variable "amis" {
  type = map
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-4b32be2b"
  }
}

variable "ssh_port" {
  default = "22"
}

variable "server_port" {
  default = "8080"
}
