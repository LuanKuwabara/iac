# VPC
variable "vpc_id" {}

# EC2 Launch Template
variable "ami" {
  type = string
  default = "ami-01cc34ab2709337aa"
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "ssh_key" {
  type = string
  default = "id_rsa"
}

#SN
variable "sn_pub_1a_id" {}

variable "sn_pub_1c_id" {}

#LB
variable "protocol" {
  type = string
  default = "HTTP"
}

variable "port" {
  type = number
  default = 80
}

#Auto Scaling
variable "desired_capacity" {
  type = number
  default = 4
}

variable "min_size" {
  type = number
  default = 4
}

variable "max_size" {
  type = number
  default = 6
}

#DB Instance
variable "rds_endpoint" {}

variable "rds_user" {}

variable "rds_password" {}

variable "rds_name" {}

variable "sg_priv_id" {} 