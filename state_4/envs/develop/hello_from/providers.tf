terraform {
  
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "3.58.0"
    }
  }

  required_version = "~>1.0.2"
}

provider "aws" {
  region  = "us-west-1"  # variables can be injected from files, too
  //profile = "tf_workshop"
}