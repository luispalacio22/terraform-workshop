terraform {
  backend "s3" {
    //profile = "tf_workshop"
    profile = "default"
    bucket  = "wwc-testing-bucket"
    key     = "luis.palacio/terraform.tfstate"
    region  = "us-west-1"
    encrypt = true
  }
}
