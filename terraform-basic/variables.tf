variable "profile" {
  default = "bbomn"
}

variable "region" {
  default = "us-east-1"
}

variable "name" {
  default = "andrew-terraform-tutorial"
}

# Server operating system image
variable "aws_instance_image" {
  default = "ubuntu_16_04_1"
}

# Size of the server we want to make
variable "aws_instance_model" {
  default = "nano_1_0"
}

variable "pvt_key" {
  default = "~/.keys/LightsailDefaultPrivateKey-us-east-1.pem"
}

variable "ssh_user" {
  default = "ubuntu"
}
