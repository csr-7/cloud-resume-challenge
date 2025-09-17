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
        profile = "crc"
  }
}
  
provider "aws" {
  region  = var.aws_region
  #profile = "crc"
}
