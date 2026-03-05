output "api_id" {
  description = "API Gateway REST API ID"
  value       = module.api_gateway.api_id
}

output "api_endpoint" {
  description = "API Gateway REST API endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "stage_name" {
  description = "API Gateway stage name"
  value       = module.api_gateway.stage_name
}

output "lambda_function_name" {
  description = "Lambda function name"
  value       = aws_lambda_function.example.function_name
}
