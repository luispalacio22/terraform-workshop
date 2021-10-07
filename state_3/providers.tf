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
  region  = var.region  # variables can be injected from files, too
  //profile = var.profile
}