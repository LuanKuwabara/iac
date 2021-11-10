# Criando a VPC
resource "aws_vpc" "vpc10" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = "${var.vpc_dns_hostname}"

  tags = {
    "Name" = "vpc10"
  }
}

# Criando o Internet Gateway
resource "aws_internet_gateway" "igw_vpc10" {
  vpc_id = aws_vpc.vpc10.id

  tags = {
    "Name" = "igw_vpc10"
  }
}

# Criando as Subnet's
resource "aws_subnet" "sn_pub_1a" {
  vpc_id = aws_vpc.vpc10.id
  cidr_block = "${var.sn_pub_1a_cidr}"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "sn_vpc10_pub_1a"
  }
}

resource "aws_subnet" "sn_pub_1c" {
  vpc_id = aws_vpc.vpc10.id
  cidr_block = "${var.sn_pub_1c_cidr}"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1c"

  tags = {
    "Name" = "sn_vpc10_pub_1c"
  }
}

resource "aws_subnet" "sn_priv_1a" {
  vpc_id = aws_vpc.vpc10.id
  cidr_block = "${var.sn_priv_1a_cidr}"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "sn_vpc10_priv_1a"
  }
}

resource "aws_subnet" "sn_priv_1c" {
  vpc_id = aws_vpc.vpc10.id
  cidr_block = "${var.sn_priv_1c_cidr}"
  availability_zone = "us-east-1c"

  tags = {
    "Name" = "sn_vpc10_priv_1c"
  }
}

# Criando Elastic IP para os NAT Gateways
resource "aws_eip" "eip_pub_1a" {
  depends_on = [aws_internet_gateway.igw_vpc10]

  tags = {
    "Name" = "eip_pub_1a"
  }
}

resource "aws_eip" "eip_pub_1c" {
  depends_on = [aws_internet_gateway.igw_vpc10]

  tags = {
    "Name" = "eip_pub_1c"
  }
}

# Criando o NAT Gateway
resource "aws_nat_gateway" "ngw_pub_1a" {
  allocation_id = aws_eip.eip_pub_1a.id
  subnet_id = aws_subnet.sn_pub_1a.id
  depends_on = [aws_internet_gateway.igw_vpc10]

  tags = {
    "Name" = "ngw_pub_1a"
  }
}

resource "aws_nat_gateway" "ngw_pub_1c" {
  allocation_id = aws_eip.eip_pub_1c.id
  subnet_id = aws_subnet.sn_pub_1c.id
  depends_on = [aws_internet_gateway.igw_vpc10]

  tags = {
    "Name" = "ngw_pub_1c"
  }
}

# Criando as tabelas de roteamento
resource "aws_route_table" "rt_pub_1a" {
  vpc_id = aws_vpc.vpc10.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw_vpc10.id
  }

  tags = {
    "Name" = "rt_pub_1a"
  }
}

resource "aws_route_table" "rt_pub_1c" {
  vpc_id = aws_vpc.vpc10.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw_vpc10.id
  }

  tags = {
    "Name" = "rt_pub_1c"
  }
}

resource "aws_route_table" "rt_priv_1a" {
  vpc_id = aws_vpc.vpc10.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.ngw_pub_1a.id
  }

  tags = {
    "Name" = "rt_priv_1a"
  }
}

resource "aws_route_table" "rt_priv_1c" {
  vpc_id = aws_vpc.vpc10.id

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.ngw_pub_1c.id
  }

  tags = {
    "Name" = "rt_priv_1c"
  }
}

# Fazendo as associações das tabelas de roteamento
resource "aws_route_table_association" "sn_pub_1a_rta" {
  subnet_id = aws_subnet.sn_pub_1a.id
  route_table_id = aws_route_table.rt_pub_1a.id
}

resource "aws_route_table_association" "sn_pub_1c_rta" {
  subnet_id = aws_subnet.sn_pub_1c.id
  route_table_id = aws_route_table.rt_pub_1c.id
}

resource "aws_route_table_association" "sn_priv_1a_rta" {
  subnet_id = aws_subnet.sn_priv_1a.id
  route_table_id = aws_route_table.rt_priv_1a.id
}

resource "aws_route_table_association" "sn_priv_1c_rta" {
  subnet_id = aws_subnet.sn_priv_1c.id
  route_table_id = aws_route_table.rt_priv_1c.id
}