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

# Example: Create a basic S3 bucket with versioning
module "s3_bucket" {
  source = "../../modules/s3"

  bucket_name        = "${var.project_name}-${var.environment}-bucket-${data.aws_caller_identity.current.account_id}"
  versioning_enabled = true

  lifecycle_rules = [
    {
      id                         = "archive-old-versions"
      expiration_days            = 90
      noncurrent_expiration_days = 30
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Example: Create an S3 bucket with Lambda notifications
module "s3_bucket_with_notifications" {
  source = "../../modules/s3"

  bucket_name        = "${var.project_name}-${var.environment}-events-${data.aws_caller_identity.current.account_id}"
  versioning_enabled = true

  lambda_notifications = [
    {
      lambda_arn    = aws_lambda_function.s3_processor.arn
      events        = ["s3:ObjectCreated:*"]
      filter_prefix = "uploads/"
      filter_suffix = ".json"
    }
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }

  depends_on = [aws_lambda_permission.s3_invoke]
}

# Data source to get current AWS account ID
data "aws_caller_identity" "current" {}

# Example Lambda function for S3 notifications
resource "aws_lambda_function" "s3_processor" {
  filename      = "lambda_function.zip"
  function_name = "${var.project_name}-s3-processor"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.12"

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-s3-lambda-role"

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

# Allow S3 to invoke Lambda
resource "aws_lambda_permission" "s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::${var.project_name}-${var.environment}-events-${data.aws_caller_identity.current.account_id}"
}
