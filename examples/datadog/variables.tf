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

variable "datadog_site" {
  type        = string
  description = "Datadog site (datadoghq.com, datadoghq.eu, etc.)"
  default     = "datadoghq.com"
}
