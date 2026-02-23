variable "api_name" {
  type        = string
  description = "Name of the API Gateway REST API"
}

variable "description" {
  type        = string
  description = "Description of the API"
  default     = ""
}

variable "environment" {
  type        = string
  description = "Deployment stage name (dev, staging, prod)"
}

variable "lambda_invoke_arn" {
  type        = string
  description = "Invoke ARN of the Lambda function to integrate with"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function — used for permission resource"
}

variable "endpoint_type" {
  type        = string
  description = "API Gateway endpoint type"
  default     = "REGIONAL"

  validation {
    condition     = contains(["REGIONAL", "EDGE", "PRIVATE"], var.endpoint_type)
    error_message = "endpoint_type must be REGIONAL, EDGE, or PRIVATE"
  }
}

variable "routes" {
  type = list(object({
    method        = string
    path          = string
    authorization = optional(string, "NONE")
    authorizer_id = optional(string, null)
    api_key_required = optional(bool, false)
  }))
  description = "List of routes to create on the API"

  validation {
    condition = alltrue([
      for r in var.routes :
      contains(["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS", "HEAD", "ANY"], r.method)
    ])
    error_message = "Each route method must be a valid HTTP method"
  }
}

variable "enable_access_logs" {
  type        = bool
  description = "Enable CloudWatch access logging for the stage"
  default     = true
}

variable "log_retention_days" {
  type        = number
  description = "CloudWatch log retention in days"
  default     = 30
}

variable "throttling_burst_limit" {
  type        = number
  description = "API Gateway burst limit (concurrent requests)"
  default     = 500
}

variable "throttling_rate_limit" {
  type        = number
  description = "API Gateway rate limit (requests per second)"
  default     = 1000
}

variable "enable_api_key" {
  type        = bool
  description = "Create an API key and usage plan for this API"
  default     = false
}

variable "cors_origins" {
  type        = list(string)
  description = "Allowed CORS origins. Empty list disables CORS"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}