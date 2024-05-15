terraform {

  backend "s3" {
    bucket                  = "scl-terraform-s3-state"
    key                     = "aws-ec2-with-asg"
    region                  = "eu-west-2"
    shared_credentials_file = "~/.aws/credentials"
  }


  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.37.0"
    }
  }

}

provider "aws" {
  region = var.region
}
