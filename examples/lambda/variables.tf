variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Project name for resource naming"
  default     = "example"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for Lambda VPC access"
  default     = []
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for Lambda security group"
  default     = ""
}

variable "db_host" {
  type        = string
  description = "Database host for Lambda environment variable"
  default     = "localhost"
}
