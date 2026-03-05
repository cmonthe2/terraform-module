output "s3_bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3_bucket.bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.bucket_arn
}

output "s3_bucket_with_notifications_id" {
  description = "ID of the S3 bucket with Lambda notifications"
  value       = module.s3_bucket_with_notifications.bucket_id
}

output "s3_bucket_with_notifications_arn" {
  description = "ARN of the S3 bucket with Lambda notifications"
  value       = module.s3_bucket_with_notifications.bucket_arn
}
