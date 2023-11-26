resource "aws_iam_role" "lambda_role" {
  name = "HelloWorldLambdaRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/function/lambda_function.py"
  output_path = "${path.module}/function/payload.zip"
}

resource "aws_lambda_function" "helloworld_function" {
  function_name = "HelloWorldFunction"
  handler      = "lambda_function.lambda_handler"
  runtime      = "python3.8"
  filename     = "${path.module}/function/payload.zip"
  role         = aws_iam_role.lambda_role.arn

  source_code_hash = data.archive_file.lambda.output_base64sha256
}

resource "aws_iam_policy" "dynamodb_policy" {
  name        = "HelloWorldDynamoPolicy"
  description = "Policy for accessing DynamoDB"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:PutItem",
          "dynamodb:DeleteItem",
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:UpdateItem",
        ],
        Resource = var.dynamodb_arn,
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_attachment" {
  policy_arn = aws_iam_policy.dynamodb_policy.arn
  role       = aws_iam_role.lambda_role.name
}