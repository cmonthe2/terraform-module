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

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Example: Create a simple Python Lambda function
module "lambda_function" {
  source = "../../modules/lambda"

  function_name = "${var.project_name}-processor"
  handler       = "lambda_function.handler"
  runtime       = "python3.12"
  zip_path      = "lambda_function.zip"
  source_hash   = filebase64sha256("lambda_function.zip")

  memory_mb      = 256
  timeout_sec    = 60
  log_retention_days = 30

  environment_variables = {
    ENVIRONMENT = var.environment
    PROJECT     = var.project_name
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Example: Create a Lambda function with VPC access
module "lambda_with_vpc" {
  source = "../../modules/lambda"

  function_name = "${var.project_name}-db-processor"
  handler       = "lambda_function.handler"
  runtime       = "python3.12"
  zip_path      = "lambda_function.zip"
  source_hash   = filebase64sha256("lambda_function.zip")

  memory_mb      = 512
  timeout_sec    = 120
  log_retention_days = 30

  # VPC configuration for database access
  vpc_config = {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  reserved_concurrency = 10

  environment_variables = {
    ENVIRONMENT = var.environment
    DB_HOST     = var.db_host
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Security group for Lambda VPC access
resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-lambda-sg"
  description = "Security group for Lambda functions"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
