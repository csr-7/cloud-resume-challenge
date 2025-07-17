# REST API
resource "aws_api_gateway_rest_api" "crc_api_tf" {
  name = "crc_api_tf"
  description = "API for Lambda to communicate with DynamoDB"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Resource for /visitor-count
resource "aws_api_gateway_resource" "visitor_count" {
  rest_api_id = aws_api_gateway_rest_api.crc_api_tf.id
  parent_id   = aws_api_gateway_rest_api.crc_api_tf.root_resource_id
  path_part   = "visitor-count"
}

# POST Method
resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.crc_api_tf.id
  resource_id   = aws_api_gateway_resource.visitor_count.id
  http_method   = "POST"
  authorization = "NONE"
}

# GET Method
resource "aws_api_gateway_method" "get_method" {
  rest_api_id   = aws_api_gateway_rest_api.crc_api_tf.id
  resource_id   = aws_api_gateway_resource.visitor_count.id
  http_method   = "GET"
  authorization = "NONE"
}

# POST Integration
resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.crc_api_tf.id
  resource_id             = aws_api_gateway_resource.visitor_count.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.python_lambda_function.invoke_arn
}

# GET Integration
resource "aws_api_gateway_integration" "get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.crc_api_tf.id
  resource_id             = aws_api_gateway_resource.visitor_count.id
  http_method             = aws_api_gateway_method.get_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.python_lambda_function.invoke_arn
}

# Lambda Permission
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.python_lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.crc_api_tf.execution_arn}/*/*"
}

# OPTIONS Method for CORS
resource "aws_api_gateway_method" "options_method" {
  rest_api_id   = aws_api_gateway_rest_api.crc_api_tf.id
  resource_id   = aws_api_gateway_resource.visitor_count.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS Integration
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.crc_api_tf.id
  resource_id             = aws_api_gateway_resource.visitor_count.id
  http_method             = "OPTIONS"
  type                    = "MOCK"
  request_templates       = {
    "application/json" = "{\n  \"statusCode\": 200\n}"
  }
  integration_http_method = "POST"
}

# Integration Response for OPTIONS
resource "aws_api_gateway_integration_response" "options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.crc_api_tf.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Method Response for OPTIONS
resource "aws_api_gateway_method_response" "options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.crc_api_tf.id
  resource_id = aws_api_gateway_resource.visitor_count.id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# Deployment
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [
    aws_api_gateway_integration.post_integration,
    aws_api_gateway_integration.get_integration,
    aws_api_gateway_integration.options_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.crc_api_tf.id
  stage_name  = "dev"
}

# Output the API Gateway URL
output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.deployment.invoke_url}/visitor-count"
  description = "URL for the visitor count API endpoint"
}
