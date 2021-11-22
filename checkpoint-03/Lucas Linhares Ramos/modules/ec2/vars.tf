variable "vpc_id" {}

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
  default = "minhachavepessoal"
}

variable "sn_pub_1a_id" {}

variable "sn_pub_1c_id" {}

variable "protocol" {
  type = string
  default = "http"
}

variable "port" {
  type = number
  default = 80
}

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
  default = 8
}

variable "rds_endpoint" {}

variable "rds_user" {}

variable "rds_password" {}

variable "rds_name" {}

variable "sg_priv_id" {}