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

variable "db_password" {
  type        = string
  description = "Database password"
  sensitive   = true
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "Private subnet IDs for database"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for security group"
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks allowed to access database"
  default     = ["10.0.0.0/8"]
}
