output "metric_stream_arn" {
  description = "ARN of the CloudWatch Metric Stream"
  value       = module.datadog_integration.metric_stream_arn
}

output "firehose_arn" {
  description = "ARN of the Kinesis Firehose"
  value       = module.datadog_integration.firehose_arn
}

output "backup_bucket_name" {
  description = "S3 bucket for failed records"
  value       = module.datadog_integration.backup_bucket_name
}
