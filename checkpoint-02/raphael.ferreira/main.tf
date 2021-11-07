provider "aws" {
  region = "us-east-1"
}
#BACKEND
terraform {
  backend "s3" {
    bucket  = "iac-be-develop-testes-terraform-rapha"
    encrypt = true
    key     = "iac/2semestre/iac/chp2"
    region  = "us-east-1"
  }
}

# vpc

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name                = "vpc10"
  }
}

# Internet GW
resource "aws_internet_gateway" "vpc-gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name              = "igw_vpc10"
  }
}



#sn-vpc-10-pub


resource "aws_subnet" "vpc-public-0" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name   = "sn_vpc10_pub_1a"
  }
}

resource "aws_subnet" "vpc-public-1c" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1c"

  tags = {
    Name   = "sn_vpc10_pub_1c"
  }
}


resource "aws_subnet" "vpc-priv-0" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"

  tags = {
    Name   = "sn_vpc10_priv_1a"
  }
}

resource "aws_subnet" "vpc-priv-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1c"

  tags = {
    Name   = "sn_vpc10_priv_1c"
  }
}


# ROUTE

resource "aws_route_table" "route-dmz" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc-gw.id
  }

  tags = {
    Name       = "igw_vpc10"
 }
}

resource "aws_route_table_association" "vpc-dmz-1" {
  subnet_id      = aws_subnet.vpc-public-0.id
  route_table_id = aws_route_table.route-dmz.id
}

resource "aws_route_table_association" "vpc-dmz-2" {
  subnet_id      = aws_subnet.vpc-public-1c.id
  route_table_id = aws_route_table.route-dmz.id
}

#nat-eip
resource "aws_eip" "main-nat" {
  vpc = true
  tags = {
    Name    = "acess_priv_internet"
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.main-nat.id
  subnet_id     = aws_subnet.vpc-public-0.id
  depends_on    = [aws_internet_gateway.vpc-gw]
  tags = {
    Name         = "ngw_vpc10" 
  }
  lifecycle {
    create_before_destroy = true
  }
}


#route_table_priv
resource "aws_route_table" "route-app" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }
  tags = {
    Name      = "rt_vpc10_private"

  }
  lifecycle {
    create_before_destroy = true
  }

}

# route associations private

resource "aws_route_table_association" "vpc-app-1" {
  subnet_id      = aws_subnet.vpc-priv-0.id
  route_table_id = aws_route_table.route-app.id
}
resource "aws_route_table_association" "vpc-app-2" {
  subnet_id      = aws_subnet.vpc-priv-1.id
  route_table_id = aws_route_table.route-app.id
}

resource "aws_sns_topic" "user_updates" {
  name            = "user-updates-topic"
  delivery_policy = <<EOF
{
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
    }
  }
}
EOF
  tags = {
     Name                               = "sns_app"
  }

}


################################################################################
# Endpoint(s)
################################################################################

resource "aws_security_group" "sgmain" {
  name        = "asg-ws"
  description = "Security group for all nodes in the cluster"
  vpc_id      = aws_vpc.vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags = {
    Name                               = "asg_ws"
  }
}

resource "aws_vpc_endpoint" "sns" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.sns"
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.sgmain.id]

  private_dns_enabled = true
  tags = {
     Name                               = "vpc_ep_vpc10"
  }
}


resource "aws_instance" "ec2-1a" {
  count                       = 2
  ami                         = "ami-02e136e904f3da870"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.vpc-public-0.id
  vpc_security_group_ids = [aws_security_group.sgmain.id]
  key_name = "gitlab-ssh"
  root_block_device {
    volume_type           =  "gp2"
    volume_size           = 8
    delete_on_termination =  true
  }
  
   tags = {
    Name = "ws_${count.index + 1}"
  }
}

resource "aws_instance" "ec2-1c" {
  count                       = 2
  ami                         = "ami-02e136e904f3da870"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.vpc-public-1c.id
  vpc_security_group_ids = [aws_security_group.sgmain.id]
  key_name = "gitlab-ssh"
  root_block_device {
    volume_type           = "gp2"
    volume_size           =  8
    delete_on_termination =  true
  }
  
   tags = {
    Name = "ws_${count.index + 3}"
  }
}

resource "aws_elb" "web" {
  name = "terraform-example-elb"

  # The same availability zone as our instances
   #availability_zones = ["us-east-1a","us-east-1c"]
   subnets = [aws_subnet.vpc-public-0.id,aws_subnet.vpc-public-1c.id]


  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # The instances are registered automatically
  instances =[aws_instance.ec2-1a.0.id,aws_instance.ec2-1a.1.id,aws_instance.ec2-1c.0.id,aws_instance.ec2-1c.1.id]
  tags = {
    Name = "elb_ws"
  }
}

resource "aws_db_subnet_group" "ehub-subnet" {
  name        = "ehub-subnet"
  description = "RDS subnet group"
  subnet_ids  = [aws_subnet.vpc-public-0.id,aws_subnet.vpc-public-1c.id]
}


resource "aws_db_instance" "ehub" {
  allocated_storage       = 100 # 100 GB of storage, gives us more IOPS than a lower number
  engine                  = "postgres"
  engine_version          = "9.6.3"
  instance_class          = "db.t2.large" # use micro if you want to use the free tier
  identifier              = "wsdb"
  name                    = "wsdb"
  username                = "root" # username
  password                = "xablaWou" # password
  db_subnet_group_name    = aws_db_subnet_group.ehub-subnet.name
  multi_az                = true # set to true to have high availability: 2 instances synchronized with each other
  vpc_security_group_ids = [aws_security_group.sgmain.id]
  storage_type            = "gp2"
  backup_retention_period = 30 # how long you’re going to keep your backups
  skip_final_snapshot     = true                             # skip final snapshot when doing terraform destroy
  tags = {
    Name                             = "ws_db"
  }
}