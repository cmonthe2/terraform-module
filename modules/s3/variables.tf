variable "bucket_name" {
  description = "The name of the S3 bucket. Must be globally unique."
  type        = string
}
   

variable "kms_key_arn" {
  description = "The ARN of the KMS key to use for server-side encryption of the S3 bucket."
  type        = string
  default     = null
}

variable "versioning_enabled" {
  description = "Whether versioning is enabled for the S3 bucket."
  type        = bool
  default     = true
}

variable "lifecycle_rules" {
  description = "The lifecycle rules for the S3 bucket."
  type = list(object({
    id                        = string
    expiration_days           = number
    noncurrent_expiration_days = number
  }))
  default = []
}

variable "lambda_notifications" {
  type = list(object({
    lambda_arn    = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default = null
}

variable "tags" {
  description = "A map of tags to assign to the S3 bucket."
  type        = map(string)
  default     = {}
}