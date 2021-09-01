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
  cidr_block           = "10.0.0.0/24"
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
  cidr_block              = "10.0.0.0/16"
  map_public_ip_on_launch = "true"
  availability_zone       = "sa-east-1a"

  tags = {
    Name = "Work Public Subnet"
  }
}
# DEFINE ROUTE TABLE
resource "aws_route_table" "work_public_route_table_local" {
  vpc_id = aws_vpc.Work_VPC.id
  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = aws_internet_gateway.Work_IGW.id
  }

  tags = {
    Name = "Public RT"
  }
}
resource "aws_route_table" "Work_IGW" {
  vpc_id = aws_vpc.Work_VPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Work_IGW.id
  }

  tags = {
    Name = "Work RT"
  }
}

# SECURITY GROUP PARA INSTANCIA
resource "aws_security_group" "Work_Nagios_Security_Group" {
  name = "Work_Nagios_Security_Group"
  description = "SG Nagios"
  vpc_id = aws_vpc.Work_VPC.id
# A regra a seguir libera saída para qualquer destino em qualquer protocolo
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
      from_port       = "0"
      to_port         = "0"
      protocol        = "-1"
      cidr_blocks = [ "0.0.0.0/0" ]
  }


}

# provisioner
resource "aws_instance" "Nagios" {
    ami = "ami-042e8287309f5df03"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.Work_Public_Subnet.id
    key_name = "checkpoint1"   
}
# provisioner
resource "aws_instance" "node_a" {
    ami = "ami-042e8287309f5df03"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.Work_Public_Subnet.id
    key_name = "checkpoint1"
}
