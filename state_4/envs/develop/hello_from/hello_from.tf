module "hello_from_develop" {
  source               = "../../../modules/hello_from"
  responsible          = "luispalacio11c@gmail.com"
  env                  = "develop"
  vpc_id               = "vpc-e7c66f81"
  app_port             = "5000"
  subnets_list         = ["subnet-40b0041a", "subnet-cb4bd3ad"]
  key_name             = "terraform-workshop-lepa"
  elb_http_port        = "80"
  asg_max_size         = 2
  asg_min_size         = 1
  asg_desired_capacity = 1
}
