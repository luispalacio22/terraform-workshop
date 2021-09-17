variable "responsible" {
  type = string
}
variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "app_port" {
  type = string
}

variable "subnets_list" {
  type = list(string)
}

variable "key_name" {
  type = string
}

variable "elb_http_port" {
  type = string
}

variable "asg_max_size" {
  type = string
}

variable "asg_min_size" {
  type = string
}

variable "asg_desired_capacity" {
  type = string
}
