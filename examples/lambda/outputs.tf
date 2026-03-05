output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = module.lambda_function.function_arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = module.lambda_function.function_name
}

output "lambda_with_vpc_arn" {
  description = "ARN of the Lambda function with VPC access"
  value       = module.lambda_with_vpc.function_arn
}

output "lambda_with_vpc_name" {
  description = "Name of the Lambda function with VPC access"
  value       = module.lambda_with_vpc.function_name
}
