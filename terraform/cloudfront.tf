resource "aws_cloudfront_origin_access_control" "crc_oac" {
  name = "OAC"
  description = "OAC created with Terraform"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.crc_resume_bucket_tf.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.crc_oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = "resume.html"

  #aliases = ["resume-tf.csruiz.com"]
  aliases = ["resume.csruiz.com"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  tags = {
    Environment = "crc-tf"
  }

  viewer_certificate {
    acm_certificate_arn = "arn:aws:acm:us-east-1:205930604749:certificate/6a18f082-4228-40ba-91e0-69219df6fbb6"
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}