# SG das EC2
resource "aws_security_group" "sg_pub" {
  name = "sg_pub"
  description = "Security Group public"
  vpc_id = "${var.vpc_id}"

  egress {
      description = "todos para todos"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      description = "todos para 10.0.0.0/16"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["10.0.0.0/16"]
  }

    ingress {
      description = "TCP/22 para todos"
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      description = "TCP/80 para todos"
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "sg_pub"
  }
}

resource "aws_security_group" "sg_priv" {
  name = "sg_priv"
  description = "Private SG"
  vpc_id = "${var.vpc_id}"

    egress {
      description = "todos para todos"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
      description = "todos para 10.0.0.0/16"
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["10.0.0.0/16"]
  }

  tags = {
    "Name" = "sg_priv"
  }
}

# LAUNCH TEMPLATE
data "template_file" "user_data" {
  template = "${file("./modules/ec2/user_data.sh")}"
  vars = {
      rds_endpoint = "${var.rds_endpoint}"
      rds_user = "${var.rds_user}"
      rds_password = "${var.rds_password}"
      rds_name = "${var.rds_name}"
  }
}

resource "aws_launch_template" "lt_notify" {
  name = "lt-notificacao"
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  vpc_security_group_ids = [aws_security_group.sg_pub.id]
  key_name = "${var.ssh_key}"
  user_data = "${base64encode(data.template_file.user_data.rendered)}"

  tag_specifications {
    resource_type = "instance"
    tags = {
      "Name" = "app_notify"
    }
  }

  tags = {
      Name = "lt_app_notify"
  }
}

#ALB
resource "aws_lb" "lb_app_notify" {
  name = "lb-app-notify"
  load_balancer_type = "application"
  subnets = ["${var.sn_pub_1a_id}", "${var.sn_pub_1c_id}"]
  security_groups = [aws_security_group.sg_pub.id]

  tags = {
    "Name" = "lb_apnotify"
  }
}

resource "aws_lb_target_group" "tg_app_notify" {
  name = "tg-app-notify"
  vpc_id = "${var.vpc_id}"
  protocol = "${var.protocol}"
  port = "${var.port}"

  tags = {
    "Name" = "tg_app_notify"
  }
}

#Listener
resource "aws_lb_listener" "listener_app_notify" {
  load_balancer_arn = aws_lb.tg_app_notify.arn
  protocol = "${var.protocol}"
  port = "${var.port}"

  default_action {
      type = "foward"
      target_group_arn = aws_lb_target_group.tg_app_notify.arn
  }
}

#Auto Scaling
resource "aws_autoscaling_group" "asg_app_notify" {
  name = "asg_app_notify"
  vpc_zone_identifier = ["${var.sn_pub_1a_id}", "${var.sn_pub_1c_id}"]
  desired_capacity = "${var.desired_capacity}"
  min_size = "${var.min_size}"
  max_size = "${var.max_size}"
  target_group_arns = [aws_lb_target_group.tg_app_notify.arn]

  launch_template {
    id = aws_launch_template.lt_notify.id
    version = "$Latest"
  }
} 