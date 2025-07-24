# S3 Bucket for website files
resource "aws_s3_bucket" "crc_resume_bucket_tf" {
  bucket = "crc-resume-bucket-tf"

  tags = {
    Name = "CRC Bucket for resume files created and populated with Terraform"
    Environment = "crc-tf"
  }
}

# Upload resume files to S3
resource "aws_s3_object" "resume_files" {
  for_each = fileset("../src/", "*")
  
  bucket = aws_s3_bucket.crc_resume_bucket_tf.id
  key    = each.value
  source = "../src/${each.value}"
  etag   = filemd5("../src/${each.value}")
  
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

resource "aws_s3_bucket_policy" "crc_resume_bucket_policy" {
  bucket = aws_s3_bucket.crc_resume_bucket_tf.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action = "s3:GetObject"
        Resource = "${aws_s3_bucket.crc_resume_bucket_tf.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

# Outputs
output "s3_bucket_name" {
  value = aws_s3_bucket.crc_resume_bucket_tf.id
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.crc_resume_bucket_tf.arn
}