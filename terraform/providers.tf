terraform {
    required_version = ">=1.0"

    required_providers {
        aws = {
        source  = "hashicorp/aws"
        version = "~> 5.0"
        }
    } 
    backend "s3" {
        bucket = "crc-tf-state-bucket-csr"  
        key    = "cloud-resume-challenge/terraform.tfstate"
        region = "us-west-1" 
  }
}
  
provider "aws" {
  region  = var.aws_region
  # profile = "crc"
  assume_role_with_web_identity {
    role_arn     = "arn:aws:iam::205930604749:role/GithubActionsRole"
    session_name = "terraform"
  }
}