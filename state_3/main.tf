locals {
  common_tags = {
    project = "terraform-workshop"
    responsible = var.responsible
  }
}
resource "aws_security_group" "terraform_workshop_app_sg" {
  name        = "terraform-workshop-app-sg-lepa"
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
  name        = "terraform-workshop-elb-sg-lepa"
  description = "Allow HTTP access"
  vpc_id      = "${var.vpc_id}"

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

resource "aws_launch_configuration" "as_conf" {
  name          = "launch-lepa"
  image_id      = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type
  security_groups = [aws_security_group.terraform_workshop_app_sg.id]
  user_data     = templatefile("templates/userdata.sh", {})

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "elb-lepa" {
  name               = "elb-lepa"
  security_groups    = [aws_security_group.terraform_workshop_elb_sg.id]
  subnets            = var.subnets_list

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

resource "aws_autoscaling_group" "autoscaling-lepa" {
  /* Autoscaling group */
  name                      = "autoscaling-lepa"
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  desired_capacity          = var.asg_desired_capacity
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = var.subnets_list
  load_balancers            = [aws_elb.elb-lepa.name]
  health_check_type         = "EC2"

   lifecycle {
    create_before_destroy = true
  }

  tags = [
    {
      key                 = "Name"
      value               = "terraform-workshop-asg"
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
