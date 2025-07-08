variable "aws_region" {
    description = "AWS Region"
    type        = string
    default     = "us-west-1"
}

variable "project_name" {
    description = "Project name"
    type        = string
    default     = "crc-aws-tf"
}

variable "environment" {
    description = "Environment"
    type        = string
    default     = "dev"
}