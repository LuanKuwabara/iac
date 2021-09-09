# DEFINIÇÃO DE PROVIDER
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# DEFINIÇÃO DA REGIÃO 
provider "aws" {
  region     = "sa-east-1"
}

# DEFINE INTERNET GATEWAY
resource "aws_internet_gateway" "Work_IGW" {
  vpc_id = aws_vpc.Work_VPC.id

  tags = {
    Name = "Work IGW"
  }
}

# DEFINE A VPC
resource "aws_vpc" "Work_VPC" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "Work VPC"
  }
}

# DEFINE SUBNET
resource "aws_subnet" "Work_Public_Subnet" {
  vpc_id                  = aws_vpc.Work_VPC.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "sa-east-1a"

  tags = {
    Name = "Work Public Subnet"
  }
}
# DEFINE ROUTE TABLE
resource "aws_route_table" "work_public_route_table_local" {
  count = var.use_aws

  vpc_id = aws_vpc.Work_VPC

  route {
    cidr_block                = "0.0.0.0/0"
    egress_only_gateway_id    = ""
    instance_id               = ""
    #ipv6_cidr_block           = ""
    nat_gateway_id            = ""
    network_interface_id      = ""
    transit_gateway_id        = ""
    vpc_peering_connection_id = ""
  }
    route {
    cidr_block                = "10.0.0.0/24"
    egress_only_gateway_id    = ""
    gateway_id                = aws_internet_gateway.Work_IGW
    instance_id               = ""
    #ipv6_cidr_block           = ""
    nat_gateway_id            = ""
    network_interface_id      = ""
    transit_gateway_id        = ""
    vpc_peering_connection_id = ""
  }
}
# SECURITY GROUP PARA INSTANCIA.
resource "aws_security_group" "Work_Nagios_Security_Group" {
  name = "Work_Nagios_Security_Group"
  description = "SG Nagios"
  vpc_id = aws_vpc.Work_VPC.id
# A regra a seguir libera saída para qualquer destino em qualquer protocolo
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

    ingress {
      from_port       = "0"
      to_port         = "0"
      protocol        = "-1"
      cidr_blocks = [ "10.0.0.0/16" ]
  }
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
}

# provisioner
resource "aws_instance" "nagios" {
    ami = "ami-042e8287309f5df03"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.Work_Public_Subnet.id
    vpc_security_group_ids = [Work_Nagios_Security_Group]
    key_name = "checkpoint1"
      tags = {
    Name = "nagios"
  }   
}
# provisioner
resource "aws_instance" "node_a" {
    ami = "ami-042e8287309f5df03"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.Work_Public_Subnet.id
    vpc_security_group_ids = [Work_Nagios_Security_Group]
    key_name = "checkpoint1"
      tags = {
    Name = "node_a"
  }
}