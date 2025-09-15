# Package Lambda function code
data "archive_file" "python_lambda_function" {
    type = "zip"
    source_file = "${path.module}/../src/lambda/lambda_counter_tf.py"
    output_path = "${path.module}/../src/lambda/lambda-tf.zip"
}

# Lambda Function
resource "aws_lambda_function" "python_lambda_function" {
    filename = data.archive_file.python_lambda_function.output_path
    function_name = "lambda_counter_tf"
    role = aws_iam_role.crc_lambda_role.arn
    handler = "lambda_counter_tf.lambda_handler"
    source_code_hash = data.archive_file.python_lambda_function.output_base64sha256
    runtime = "python3.11"
    description      = "Visitor counter function uploaded with Terraform"

    tags = {
        Name = "Lambda Function written in Python and pushed through Terraform for ${var.project_name}"
        Environment = var.environment
    }
}

