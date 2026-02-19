variable "function_name" {
  type        = string
  description = "Name of the Lambda function"
}

variable "handler" {
  type        = string
  description = "Handler in format filename.function_name"
  default     = "lambda_function.handler"
}

variable "runtime" {
  type        = string
  description = "Lambda runtime"
  default     = "python3.12"

  validation {
    condition     = contains(["python3.11", "python3.12", "nodejs20.x", "java21"], var.runtime)
    error_message = "Runtime must be python3.11, python3.12, nodejs20.x, or java21"
  }
}

variable "zip_path" {
  type        = string
  description = "Path to the Lambda deployment zip"
}

variable "source_hash" {
  type        = string
  description = "Base64 SHA256 of zip — triggers redeploy on change"
}

variable "memory_mb" {
  type        = number
  description = "Lambda memory in MB"
  default     = 256

  validation {
    condition     = var.memory_mb >= 128 && var.memory_mb <= 10240
    error_message = "Memory must be between 128 MB and 10240 MB"
  }
}

variable "timeout_sec" {
  type        = number
  description = "Lambda timeout in seconds"
  default     = 30

  validation {
    condition     = var.timeout_sec >= 1 && var.timeout_sec <= 900
    error_message = "Timeout must be between 1 and 900 seconds"
  }
}

variable "environment_variables" {
  type        = map(string)
  description = "Environment variables for the Lambda function"
  default     = {}
}

variable "account_id" {
  type        = string
  description = "AWS account ID"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days"
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365], var.log_retention_days)
    error_message = "log_retention_days must be a valid CloudWatch retention value"
  }
}

variable "vpc_config" {
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  description = "Optional VPC configuration for the Lambda function"
  default     = null
}

variable "reserved_concurrency" {
  type        = number
  description = "Reserved concurrency limit. -1 means unreserved"
  default     = -1
}

variable "layers" {
  type        = list(string)
  description = "List of Lambda layer ARNs"
  default     = []
}

variable "additional_policy_statements" {
  type = list(object({
    sid       = string
    effect    = string
    actions   = list(string)
    resources = list(string)
  }))
  description = "Additional IAM policy statements for the execution role"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}