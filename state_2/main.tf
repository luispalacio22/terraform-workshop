locals {
  common_tags = {
    /* Tags */
    responsible = "luispalacio11c@gmail.com"
  }
}
resource "aws_security_group" "terraform_workshop" {
  name        = "terraform-workshop-sg-lepa2"
  description = "Allow HTTP and SSH access"
  vpc_id      = "vpc-e7c66f81"

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
    values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "tf_workshop" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.terraform_workshop.id]
  subnet_id              = "subnet-40b0041a"
  //key_name               = "terraform-workshop"
  user_data              = templatefile("userdata.sh", {})
  count                  = 2

  tags = merge({Name="hello-from-be"},local.common_tags)

  volume_tags = merge({Name="hello-from-be"},local.common_tags)
}
