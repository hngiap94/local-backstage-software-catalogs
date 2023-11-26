output "function_arn" {
  value = aws_lambda_function.helloworld_function.arn
}

output "invoke_arn" {
  value = aws_lambda_function.helloworld_function.invoke_arn
}