resource "aws_iam_role" "api_gateway_role" {
  name = "APIGatewayRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "api_gateway_policy" {
  name = "APIGatewayPolicy"

  policy = jsonencode(
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": var.function_arn
    }
  ]
})
}

resource "aws_iam_role_policy_attachment" "api_gateway_policy_attachment" {
  policy_arn = aws_iam_policy.api_gateway_policy.arn
  role       = aws_iam_role.api_gateway_role.name
}

resource "aws_api_gateway_rest_api" "helloworld_api" {
  name        = "HelloWorldAPI"
  description = "Hello World API"

  endpoint_configuration {
    types = ["EDGE"]
  }
}

# POST method
resource "aws_api_gateway_method" "post_method" {
  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  resource_id = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  http_method = "POST"
  authorization = "NONE"
}

# POST integration lambda
resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.helloworld_api.id
  resource_id             = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  http_method             = aws_api_gateway_method.post_method.http_method
  credentials             = aws_iam_role.api_gateway_role.arn
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = var.invoke_arn
}

# POST method response
resource "aws_api_gateway_method_response" "post_method_response" {
  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  resource_id = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  
  response_models = {
    "application/json" = "Empty"
  }
}

# POST lambda integration response
resource "aws_api_gateway_integration_response" "post_lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  resource_id = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  http_method = aws_api_gateway_method.post_method.http_method
  status_code = aws_api_gateway_method_response.post_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  response_templates    = {
    "application/json" = ""
  }
}

# OPTIONS method
resource "aws_api_gateway_method" "options_method" {
  rest_api_id      = aws_api_gateway_rest_api.helloworld_api.id
  resource_id      = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  http_method      = "OPTIONS"
  authorization    = "NONE"
  api_key_required = false
}

# OPTIONS integration lambda
resource "aws_api_gateway_integration" "options_integration" {
  rest_api_id             = aws_api_gateway_rest_api.helloworld_api.id
  resource_id             = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  http_method             = aws_api_gateway_method.options_method.http_method
  type                    = "MOCK"
  passthrough_behavior = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
}

# OPTIONS method response
resource "aws_api_gateway_method_response" "options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  resource_id = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
  
  response_models = {
    "application/json" = "Empty"
  }
}

# OPTIONS lambda integration response
resource "aws_api_gateway_integration_response" "options_lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  resource_id = aws_api_gateway_rest_api.helloworld_api.root_resource_id
  http_method = aws_api_gateway_method.options_method.http_method
  status_code = aws_api_gateway_method_response.options_method_response.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'OPTIONS,POST'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# Deploy API
resource "aws_api_gateway_deployment" "deployment" {
  depends_on = [aws_api_gateway_integration.post_integration, aws_api_gateway_integration.options_integration]

  rest_api_id = aws_api_gateway_rest_api.helloworld_api.id
  stage_name  = "dev"
}