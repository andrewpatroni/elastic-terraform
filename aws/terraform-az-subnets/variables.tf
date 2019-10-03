variable "aws_access_key" {
    type = "string"
}

variable "aws_secret_key" {
    type = "string"
}

variable "aws_region" {
    type = "string"
}

variable "aws_ami" {
    type = "string"
}

variable "aws_instance_type" {
    type = "string"
}

variable "aws_key_pair" {
    type = "string"
}

variable "home_ip" {
  type = "string"
}
variable "aws_avail_zone_1" {
  type = "string"
}
variable "aws_avail_zone_2" {
  type = "string"
}
variable "aws_avail_zone_3" {
  type = "string"
}
variable "az1_subnet_cidr_block" {
  type = "string"
}
variable "az2_subnet_cidr_block" {
  type = "string"
}
variable "az3_subnet_cidr_block" {
  type = "string"
}

variable "vpc_cidr_block" {
  type = "string"
}

variable "ami_user" {
  type = "string"
}
