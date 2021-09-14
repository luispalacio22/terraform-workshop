variable "region" {
  type    = "string"
  default = "us-east-1"
}

variable "profile" {
  type    = "string"
  default = "default"
}

variable vpc_id {
  type = "string"
}

variable app_port {
  type = "string"
}

variable "instance_type" {
  type = "string"
}

variable "subnet_id" {
  type = "string"
}

variable "key_name" {
  type = "string"
}

variable instances {
  type    = "string"
  default = "1"
}
