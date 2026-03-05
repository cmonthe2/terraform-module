output "metric_stream_arn" {
  description = "ARN of the CloudWatch Metric Stream"
  value       = aws_cloudwatch_metric_stream.datadog.arn
}

output "firehose_arn" {
  description = "ARN of the Kinesis Firehose delivery stream"
  value       = aws_kinesis_firehose_delivery_stream.datadog.arn
}

output "backup_bucket_name" {
  description = "S3 bucket name for failed records backup"
  value       = aws_s3_bucket.firehose_backup.id
}

output "metric_stream_name" {
  description = "Name of the CloudWatch Metric Stream"
  value       = aws_cloudwatch_metric_stream.datadog.name
}
