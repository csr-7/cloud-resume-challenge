# S3 Bucket for website files
resource "aws_s3_bucket" "crc-resume-bucket-tf" {
  bucket = "crc-resume-bucket-tf"
}

# S3 Bucket tags (separate resource in newer provider versions)
resource "aws_s3_bucket_tagging" "crc_bucket_tags" {
  bucket = aws_s3_bucket.crc-resume-bucket-tf.id
  
  tags = {
    Name        = "CRC Bucket for resume files created and populated with Terraform"
    Environment = "crc-tf"
  }
}

# S3 bucket policy - NOTE: This will be updated when we create CloudFront
resource "aws_s3_bucket_policy" "allow_cloudfront_access" {
  bucket = aws_s3_bucket.crc-resume-bucket-tf.id
  policy = data.aws_iam_policy_document.allow_cloudfront_access.json
}

# Upload resume files to S3
resource "aws_s3_object" "resume_files" {
  for_each = fileset("../../src/", "*")
  
  bucket = aws_s3_bucket.crc-resume-bucket-tf.id
  key    = each.value
  source = "../../src/${each.value}"
  etag   = filemd5("../../src/${each.value}")
  
  # Set content type based on file extension
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css" 
    "js"   = "application/javascript"
    "json" = "application/json"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "svg"  = "image/svg+xml"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}

# IAM policy document for CloudFront access
# NOTE: This is a placeholder - we'll need to update this with the actual CloudFront OAC
data "aws_iam_policy_document" "allow_cloudfront_access" {
  statement {
    sid = "AllowCloudFrontServicePrincipal"
    
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.crc-resume-bucket-tf.arn}/*"
    ]

    # This condition will need to be updated when we create CloudFront
    # condition {
    #   test     = "StringEquals"
    #   variable = "AWS:SourceArn"
    #   values   = [aws_cloudfront_distribution.website_distribution.arn]
    # }
  }
}

# Outputs
output "s3_bucket_name" {
  value = aws_s3_bucket.crc-resume-bucket-tf.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.crc-resume-bucket-tf.arn
}