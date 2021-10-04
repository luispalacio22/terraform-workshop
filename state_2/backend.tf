terraform {
  backend "s3" {
    profile = "default"
    bucket  = "wwc-testing-bucket"
    key= "lepa-22.tfstate"
    region  = "us-west-1"
    encrypt = true
  }
}
