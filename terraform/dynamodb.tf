resource "aws_dynamodb_table" "visitors_table" {
    name                        = "resume-visitors-tf"
    billing_mode                = "PAY_PER_REQUEST" #on-demand billing 
    deletion_protection_enabled =  true
    hash_key                    = "id"

    attribute {
        name                    = "id"
        type                    = "S"
    }

    tags = {
        Name                    = "DynamoDB Table to store visit count for ${var.project_name}"
        Environment             = var.environment
    }
}