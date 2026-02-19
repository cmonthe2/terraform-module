variable "queue_name" {
  type        = string
  description = "Name of the SQS queue"
}

variable "visibility_timeout_seconds" {
  type        = number
  description = "How long a message is hidden after being received. Must be >= Lambda timeout"
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "visibility_timeout_seconds must be between 0 and 43200"
  }
}

variable "message_retention_seconds" {
  type        = number
  description = "How long SQS retains a message before deleting it"
  default     = 345600   # 4 days

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds must be between 60 (1 min) and 1209600 (14 days)"
  }
}

variable "max_receive_count" {
  type        = number
  description = "Number of times a message can be received before going to DLQ"
  default     = 3
}

variable "batch_size" {
  type        = number
  description = "Number of messages Lambda receives per invocation"
  default     = 10

  validation {
    condition     = var.batch_size >= 1 && var.batch_size <= 10000
    error_message = "batch_size must be between 1 and 10000"
  }
}

variable "maximum_batching_window_seconds" {
  type        = number
  description = "Max time Lambda waits to fill a batch before invoking. 0 = invoke immediately"
  default     = 0
}

variable "lambda_function_arn" {
  type        = string
  description = "ARN of the Lambda function to trigger from this queue"
}

variable "lambda_function_name" {
  type        = string
  description = "Name of the Lambda function — used for IAM policy"
}

variable "lambda_role_name" {
  type        = string
  description = "Execution role name of the Lambda — SQS read permissions attached here"
}

variable "fifo_queue" {
  type        = bool
  description = "Create a FIFO queue for strict ordering"
  default     = false
}

variable "content_based_deduplication" {
  type        = bool
  description = "Enable content-based deduplication (FIFO queues only)"
  default     = false
}

variable "kms_key_arn" {
  type        = string
  description = "KMS key ARN for server-side encryption. Null uses SQS managed keys"
  default     = null
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}