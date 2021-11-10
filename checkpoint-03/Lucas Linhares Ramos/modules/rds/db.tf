# Definindo o DB Subnet Group do Banco de dados
resource "aws_db_subnet_group" "sn_group" {
  name = "subnet_group"
  subnet_ids = ["${var.sn_priv_1a_id}", "${var.sn_priv_1c_id}"]

  tags = {
    "Name" = "sn_group_db"
  }
}

# Definindo o Parameter Group
resource "aws_db_parameter_group" "parameter_group" {
  name = "parameter-group"
  family = "${var.family}"

  parameter {
    name = "character_set_server"
    value = "${var.charset}"
  }
}

# Criando a instância rds
resource "aws_db_instance" "db_notificacao" {
  identifier = "db-notificacao"
  engine = "${var.engine}"
  engine_version = "${var.engine_version}"
  instance_class = "${var.instance_class}"
  storage_type = "${var.storage_type}"
  allocated_storage = "${var.allocated_storage}"
  max_allocated_storage = 0
  monitoring_interval = 0
  name = "${var.db_name}"
  username = "${var.db_user}"
  password = "${var.db_password}"
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.sn_group.name
  parameter_group_name = aws_db_parameter_group.parameter_group.name
  availability_zone = "us-east-1a"
  vpc_security_group_ids = ["${var.sg_priv_id}"]

  tags = {
    "Name" = "db_notificacao"
  }
}