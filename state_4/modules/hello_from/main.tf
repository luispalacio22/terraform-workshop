locals {
  common_tags = {
    project = "terraform-workshop"
    responsible = var.responsible
  }
  ec2_instance_type = var.env == "develop" ? "t2.micro" : "t2.small"
}
resource "aws_security_group" "terraform_workshop_app_sg" {
  name        = "terraform-workshop-app-sg-${var.env}"
  description = "Allow HTTP access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_security_group" "terraform_workshop_elb_sg" {
  name        = "terraform-workshop-elb-sg-${var.env}"
  description = "Allow HTTP access"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = var.elb_http_port
    to_port     = var.elb_http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-*-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_launch_configuration" "launch_configuration" {
  name_prefix     = "terraform-workshop-${var.env}-${local.ec2_instance_type}-${data.aws_ami.latest_amazon_linux.id}-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = local.ec2_instance_type
  //key_name        = var.key_name
  security_groups = [aws_security_group.terraform_workshop_app_sg.id]
  user_data       = templatefile("${path.module}/templates/userdata.sh", {})

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "elb" {
  name            = "terraform-workshop-elb-${var.env}"
  subnets         = var.subnets_list
  security_groups = [aws_security_group.terraform_workshop_elb_sg.id]

  listener {
    instance_port     = var.app_port
    instance_protocol = "tcp"
    lb_port           = var.elb_http_port
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "TCP:${var.app_port}"
    interval            = 30
  }

  tags = local.common_tags
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.launch_configuration.name
  vpc_zone_identifier  = var.subnets_list
  max_size             = var.asg_max_size
  min_size             = var.asg_min_size
  desired_capacity     = var.asg_desired_capacity
  load_balancers       = [aws_elb.elb.name]
  health_check_type    = "EC2"

  lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "terraform-workshop-asg-${var.env}"
      propagate_at_launch = true
    },
    {
      key = "project"
      value = local.common_tags["project"]
      propagate_at_launch = true
    },
    {
      key = "responsible"
      value = local.common_tags["responsible"]
      propagate_at_launch = true
    }
  ]
}
