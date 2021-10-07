terraform {
  backend "s3" {
    profile = "default"
    bucket  = "wwc-testing-bucket"
    key     = "luis.palacio/prod/terraform.tfstate"
    region  = "us-west-1"
    encrypt = true
  }
}
