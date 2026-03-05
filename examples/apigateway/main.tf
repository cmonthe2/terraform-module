terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Example: Create a simple REST API with Lambda integration
module "api_gateway" {
  source = "../../modules/apigateway"

  api_name    = "${var.project_name}-api"
  description = "Example REST API with Lambda integration"
  environment = var.environment

  # Reference to a Lambda function (you would create this separately)
  lambda_invoke_arn = aws_lambda_function.example.invoke_arn

  # Define API routes
  routes = [
    {
      method = "GET"
      path   = "/health"
    },
    {
      method = "POST"
      path   = "/users"
    },
    {
      method = "GET"
      path   = "/users/{user_id}"
    },
    {
      method = "PUT"
      path   = "/users/{user_id}"
    },
    {
      method = "DELETE"
      path   = "/users/{user_id}"
    }
  ]

  enable_access_logs      = true
  log_retention_days      = 30
  throttling_burst_limit  = 500
  throttling_rate_limit   = 1000
  enable_api_key          = false
  cors_origins            = ["https://example.com", "https://app.example.com"]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Example Lambda function for API integration
resource "aws_lambda_function" "example" {
  filename      = "lambda_function.zip"
  function_name = "${var.project_name}-api-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
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

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
