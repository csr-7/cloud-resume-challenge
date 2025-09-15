# Outputs
output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.s3_distribution.domain_name
  description = "CloudFront distribution domain name"
}

output "cloudfront_distribution_id" {
  value       = aws_cloudfront_distribution.s3_distribution.id
  description = "CloudFront distribution ID"
}

terraform {
  backend "s3" {
    bucket = "crc-tf-state-bucket-csr"  
    key    = "cloud-resume-challenge/terraform.tfstate"
    region = "us-west-1" 
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}