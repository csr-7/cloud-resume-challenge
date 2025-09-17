# Creating the IAM Role
resource "aws_iam_role" "crc_lambda_role" {
    name = "${var.project_name}-lambda-role"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Creating the IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions_role" {
  name = "GithubActionsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = "arn:aws:iam::205930604749:oidc-provider/token.actions.githubusercontent.com"
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:csr-7/cloud-resume-challenge:*"
          }
        }
      }
    ]
  })
}

# Assigning the permissions to the role
resource "aws_iam_role_policy" "crc_lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.crc_lambda_role.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = aws_dynamodb_table.visitors_table.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      }
    ]
  })
}

#assigning the permissions to the GitHub Actions role
resource "aws_iam_role_policy" "github_actions_policy" {
  name = "GithubActionsPolicy"
  role = aws_iam_role.github_actions_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "ResumeBucketAccess",
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetObjectTagging",
          "s3:ListBucket",
          "s3:ListBucketVersions",
          "s3:PutBucketCORS",
          "s3:GetBucketCORS",
          "s3:PutBucketPolicy",
          "s3:GetBucketPolicy",
          "s3:GetBucketAcl",
          "s3:GetBucketWebsite",
          "s3:GetBucketVersioning",
          "s3:GetBucketRequestPayment",
          "s3:GetBucketLogging",
          "s3:GetBucketObjectLockConfiguration",
          "s3:GetBucketTagging",
          "s3:GetAccelerateConfiguration",
          "s3:GetLifecycleConfiguration",
          "s3:GetReplicationConfiguration",
          "s3:GetEncryptionConfiguration"
        ],
        Resource = [
          "arn:aws:s3:::crc-resume-bucket-tf",
          "arn:aws:s3:::crc-resume-bucket-tf/*"
        ]
      },
      {
        Sid    = "StateBucketAccess",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::crc-tf-state-bucket-csr",
          "arn:aws:s3:::crc-tf-state-bucket-csr/*"
        ]
      },
      {
        Sid    = "CloudFrontAccess",
        Effect = "Allow",
        Action = [
          "cloudfront:CreateOriginAccessControl",
          "cloudfront:GetOriginAccessControl",
          "cloudfront:UpdateOriginAccessControl",
          "cloudfront:DeleteOriginAccessControl"
        ],
        Resource = "*"
      },
      {
        Sid    = "ApiGatewayAccess",
        Effect = "Allow",
        Action = [
          "apigateway:GET",
          "apigateway:POST",
          "apigateway:PUT",
          "apigateway:DELETE",
          "apigateway:PATCH"
        ],
        Resource = "arn:aws:apigateway:us-west-1::/restapis*"
      },
      {
        Sid    = "DynamoDBAccess",
        Effect = "Allow",
        Action = [
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "dynamodb:DescribeContinuousBackups",
          "dynamodb:DescribeTimeToLive",
          "dynamodb:ListTables",
          "dynamodb:ListTagsOfResource",
          "dynamodb:UpdateTable"
        ],
        Resource = "arn:aws:dynamodb:us-west-1:205930604749:table/resume-visitors-tf"
      },
      {
        Sid    = "IAMAccessForLambdaRole",
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:DeleteRole",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:ListRolePolicies",
          "iam:PassRole"
        ],
        Resource = "arn:aws:iam::205930604749:role/crc-aws-tf-lambda-role"
      },
      {
        Sid    = "LogsAccess",
        Effect = "Allow",
        Action = "logs:*",
        Resource = "*"
      }
    ]
  })
}
