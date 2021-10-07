  # PROVIDER
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# REGION
provider "aws" {
    region = "us-east-1"
}
# VPC10
resource "aws_vpc" "vpc10" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
        Name = "vpc10"  
    }
}
# VPC20
resource "aws_vpc" "vpc20" {
    cidr_block           = "20.0.0.0/16"
    enable_dns_hostnames = "true"

    tags = {
        Name = "vpc20"  
    }
}
resource "aws_vpc_peering_connection" "vpcpeer" {
  peer_vpc_id   = aws_vpc.vpc20.id
  vpc_id        = aws_vpc.vpc10.id
  auto_accept   = true

  tags = {
    Name = "vpcpeer"
  }
}

# INTERNET GATEWAY VPC10
resource "aws_internet_gateway" "igw_vpc10" {
    vpc_id = aws_vpc.vpc10.id

    tags = {
        Name = "igw_vpc10"
    }
}
# INTERNET GATEWAY VPC20
resource "aws_internet_gateway" "igw_vpc20" {
    vpc_id = aws_vpc.vpc20.id

    tags = {
        Name = "igw_vpc20"
    }
}
# PUBLIC SUBNET VPC10
resource "aws_subnet" "sn_vpc10_public" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc10_public"
    }
}
# PUBLIC SUBNET VPC20
resource "aws_subnet" "sn_vpc20_public" {
    vpc_id                  = aws_vpc.vpc20.id
    cidr_block              = "20.0.1.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1a"

    tags = {
        Name = "sn_vpc20_public"
    }
}
# PRIVATE SUBNET VPC10
resource "aws_subnet" "sn_vpc10_private" {
    vpc_id                  = aws_vpc.vpc10.id
    cidr_block              = "10.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc10_private"
    }
}
# PRIVATE SUBNET VPC20
resource "aws_subnet" "sn_vpc20_private" {
    vpc_id                  = aws_vpc.vpc20.id
    cidr_block              = "20.0.2.0/24"
    map_public_ip_on_launch = "true"
    availability_zone       = "us-east-1c"

    tags = {
        Name = "sn_vpc20_private"
    }
}
# ROUTE TABLE VPC10 PUBLIC
resource "aws_route_table" "rt_vpc10_public" {
    vpc_id = aws_vpc.vpc10.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc10.id
    }
        route {
        cidr_block = "20.0.0.0/16"
        vpc_peering_connection_id = aws_vpc_peering_connection.vpcpeer.id
    }

    tags = {
        Name = "rt_vpc10_public"
    }
}
# ROUTE TABLE VPC10 PRIVATE
resource "aws_route_table" "rt_vpc10_private" {
    vpc_id = aws_vpc.vpc10.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc10.id
    }
        route {
        cidr_block = "20.0.0.0/16"
        vpc_peering_connection_id = aws_vpc_peering_connection.vpcpeer.id
    }

    tags = {
        Name = "rt_vpc10_private"
    }
}
# ROUTE TABLE VPC10 PUBLIC
resource "aws_route_table" "rt_vpc20_public" {
    vpc_id = aws_vpc.vpc20.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc20.id
    }
        route {
        cidr_block = "10.0.0.0/16"
        vpc_peering_connection_id = aws_vpc_peering_connection.vpcpeer.id
    }

    tags = {
        Name = "rt_vpc20_public"
    }
}
# ROUTE TABLE VPC20 PRIVATE
resource "aws_route_table" "rt_vpc20_private" {
    vpc_id = aws_vpc.vpc20.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw_vpc20.id
    }
        route {
        cidr_block = "10.0.0.0/16"
        vpc_peering_connection_id = aws_vpc_peering_connection.vpcpeer.id
    }

    tags = {
        Name = "rt_vpc20_private"
    }
}
#PUBLIC SUBNET ASSOCIATION VPC10
resource "aws_route_table_association" "public_vpc10" {
  subnet_id      = aws_subnet.sn_vpc10_public.id
  route_table_id = aws_route_table.rt_vpc10_public.id
}
#PRIVATE SUBNET ASSOCIATION VPC10
resource "aws_route_table_association" "private_vpc10" {
  subnet_id      = aws_subnet.sn_vpc10_private.id
  route_table_id = aws_route_table.rt_vpc10_private.id
}
#PUBLIC SUBNET ASSOCIATION VPC20
resource "aws_route_table_association" "public_vpc20" {
  subnet_id      = aws_subnet.sn_vpc20_public.id
  route_table_id = aws_route_table.rt_vpc20_public.id
}
#PRIVATE SUBNET ASSOCIATION VPC10
resource "aws_route_table_association" "private_vpc20" {
  subnet_id      = aws_subnet.sn_vpc20_private.id
  route_table_id = aws_route_table.rt_vpc20_private.id
}
 #ELASTIC IP PUBLIC SN1
 resource "aws_eip" "Nat1eIP" {
   vpc   = true
   depends_on = [
     aws_internet_gateway.igw_vpc10
   ]
 }
 #NAT GATEWAY PUBLIC SN1
  resource "aws_nat_gateway" "NAT1gw" {
   allocation_id = aws_eip.Nat1eIP.id
   subnet_id = aws_subnet.sn_vpc10_public.id
   depends_on = [
     aws_internet_gateway.igw_vpc10
   ]
 }
 #ELASTIC IP PUBLIC SN2
 resource "aws_eip" "Nat2eIP" {
   vpc   = true
      depends_on = [
     aws_internet_gateway.igw_vpc20
   ]
 }
 #NAT GATEWAY PUBLIC SN2
  resource "aws_nat_gateway" "NAT2gw" {
   allocation_id = aws_eip.Nat2eIP.id
   subnet_id = aws_subnet.sn_vpc20_public.id
   depends_on = [
     aws_internet_gateway.igw_vpc20
   ]
 }
# VPC10 PUBLIC SECURITY GROUP
resource "aws_security_group" "sg_vpc10_public" {
    name        = "sg_vpc10_public"
    description = "sg_vpc10_public"
    vpc_id = aws_vpc.vpc10.id

        egress {
        description = "All to All"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "10.0.0.0/16" ]
    }
        ingress {
        description = "All from 20.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "20.0.0.0/16" ]
    }
        ingress {
        description = "TCP/22 from All"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "TCP/80 from All"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "TCP/3389 from All"
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# VPC10 PRIVATE SECURITY GROUP
resource "aws_security_group" "sg_vpc10_private" {
    name        = "sg_vpc10_private"
    description = "sg_vpc10_private"
    vpc_id = aws_vpc.vpc10.id
        egress {
        description = "All to All"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "10.0.0.0/16" ]
    }
            ingress {
        description = "All from 20.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "20.0.0.0/16" ]
    }
}
# VPC20 PUBLIC SECURITY GROUP
resource "aws_security_group" "sg_vpc20_public" {
    name        = "sg_vpc20_public"
    description = "sg_vpc20_public"
    vpc_id = aws_vpc.vpc20.id

        egress {
        description = "All to All"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "10.0.0.0/16" ]
    }
        ingress {
        description = "All from 20.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "20.0.0.0/16" ]
    }
        ingress {
        description = "TCP/22 from All"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    ingress {
        description = "TCP/80 from All"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        description = "TCP/3389 from All"
        from_port   = 3389
        to_port     = 3389
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
# VPC20 PRIVATE SECURITY GROUP
resource "aws_security_group" "sg_vpc20_private" {
    name        = "sg_vpc20_private"
    description = "sg_vpc20_private"
    vpc_id = aws_vpc.vpc20.id
        egress {
        description = "All to All"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
        ingress {
        description = "All from 10.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "10.0.0.0/16" ]
    }
            ingress {
        description = "All from 20.0.0.0/16"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = [ "20.0.0.0/16" ]
    }
}
# EC2 INSTANCE (nagios)
resource "aws_instance" "nagios" {
    ami                    = "ami-087c17d1fe0178315"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_vpc10_public.id
    vpc_security_group_ids = [aws_security_group.sg_vpc10_public.id]
}

# EC2 INSTANCE (node_a)
resource "aws_instance" "node_a" {
    ami                    = "ami-087c17d1fe0178315"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_vpc10_public.id
    vpc_security_group_ids = [aws_security_group.sg_vpc10_public.id]
}
# EC2 INSTANCE (node_c)
resource "aws_instance" "node_c" {
    ami                    = "ami-087c17d1fe0178315"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_vpc10_private.id
    vpc_security_group_ids = [aws_security_group.sg_vpc10_private.id]
}
# EC2 INSTANCE (node_b)
resource "aws_instance" "node_b" {
    ami                    = "ami-087c17d1fe0178315"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_vpc20_public.id
    vpc_security_group_ids = [aws_security_group.sg_vpc20_public.id]
}
# EC2 INSTANCE (node_d)
resource "aws_instance" "node_d" {
    ami                    = "ami-087c17d1fe0178315"
    instance_type          = "t2.micro"
    subnet_id              = aws_subnet.sn_vpc20_private.id
    vpc_security_group_ids = [aws_security_group.sg_vpc20_private.id]
}