terraform {
  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.0"
    }
  }
}

# CloudWatch Metric Stream to Datadog
resource "aws_cloudwatch_metric_stream" "datadog" {
  name          = "${var.environment}-datadog-metric-stream"
  role_arn      = aws_iam_role.metric_stream_role.arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.datadog.arn
  output_format = "json"

  include_filter {
    namespace = "AWS/Lambda"
  }

  include_filter {
    namespace = "AWS/ApiGateway"
  }

  include_filter {
    namespace = "AWS/RDS"
  }

  include_filter {
    namespace = "AWS/S3"
  }

  include_filter {
    namespace = "AWS/SQS"
  }

  include_filter {
    namespace = "AWS/Events"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-datadog-stream"
      Environment = var.environment
    }
  )
}

# Kinesis Firehose to deliver metrics to Datadog
resource "aws_kinesis_firehose_delivery_stream" "datadog" {
  name                 = "${var.environment}-datadog-firehose"
  destination          = "http_endpoint"
  delivery_stream_type = "DirectPut"

  http_endpoint_configuration {
    url      = "https://aws-metric-stream.${var.datadog_site}.datadoghq.com/v2/intake"
    name     = "Datadog"
    role_arn = aws_iam_role.firehose_role.arn
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_logs.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_logs.name
    }

    request_configuration {
      content_encoding = "GZIP"
    }

    retry_configuration {
      duration_in_seconds = 3600
    }

    s3_backup_mode = "FailedDataOnly"
  }

  s3_configuration {
    role_arn            = aws_iam_role.firehose_role.arn
    bucket_arn          = aws_s3_bucket.firehose_backup.arn
    prefix              = "datadog-failed/"
    error_output_prefix = "datadog-errors/"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_s3_logs.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_s3_logs.name
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-datadog-firehose"
      Environment = var.environment
    }
  )
}

# S3 bucket for failed records
resource "aws_s3_bucket" "firehose_backup" {
  bucket = "${var.project_name}-datadog-backup-${data.aws_caller_identity.current.account_id}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-datadog-backup"
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket_versioning" "firehose_backup" {
  bucket = aws_s3_bucket.firehose_backup.id
  versioning_configuration {
    status = "Enabled"
  }
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "firehose_logs" {
  name              = "/aws/kinesisfirehose/${var.environment}-datadog"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-datadog-firehose-logs"
      Environment = var.environment
    }
  )
}

resource "aws_cloudwatch_log_stream" "firehose_logs" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_logs.name
}

resource "aws_cloudwatch_log_group" "firehose_s3_logs" {
  name              = "/aws/kinesisfirehose/${var.environment}-datadog-s3"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-datadog-s3-logs"
      Environment = var.environment
    }
  )
}

resource "aws_cloudwatch_log_stream" "firehose_s3_logs" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_s3_logs.name
}

# IAM Roles
resource "aws_iam_role" "metric_stream_role" {
  name = "${var.project_name}-metric-stream-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "streams.cloudwatch.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-metric-stream-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy" "metric_stream_policy" {
  name = "${var.project_name}-metric-stream-policy"
  role = aws_iam_role.metric_stream_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "firehose:PutRecord",
          "firehose:PutRecordBatch"
        ]
        Resource = aws_kinesis_firehose_delivery_stream.datadog.arn
      }
    ]
  })
}

resource "aws_iam_role" "firehose_role" {
  name = "${var.project_name}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-firehose-role"
      Environment = var.environment
    }
  )
}

resource "aws_iam_role_policy" "firehose_policy" {
  name = "${var.project_name}-firehose-policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.firehose_backup.arn,
          "${aws_s3_bucket.firehose_backup.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents"
        ]
        Resource = [
          "${aws_cloudwatch_log_group.firehose_logs.arn}:*",
          "${aws_cloudwatch_log_group.firehose_s3_logs.arn}:*"
        ]
      }
    ]
  })
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}
