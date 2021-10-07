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
    from_port   = "${var.elb_http_port}"
    to_port     = "${var.elb_http_port}"
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
  user_data     = templatefile("templates/userdata.sh", {})
}

resource "aws_lb" "elb-lepa" {
  name               = "elb-lepa"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.terraform_workshop_elb_sg.id]
  subnets            = var.subnets_list

  enable_deletion_protection = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {responsible="luispalacio11c@gmail.com"}
}

resource "aws_autoscaling_group" "autoscaling-lepa" {
  /* Autoscaling group */
  name                      = "autoscaling-lepa"
  max_size                  = var.asg_max_size
  min_size                  = var.asg_min_size
  health_check_grace_period = 300
  //health_check_type         = "ELB"
  desired_capacity          = var.asg_desired_capacity
  force_delete              = true
  //placement_group           = aws_placement_group.test.id
  launch_configuration      = aws_launch_configuration.as_conf.name
  vpc_zone_identifier       = var.subnets_list

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
