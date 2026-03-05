# Datadog Integration Module

This module sets up AWS CloudWatch Metric Stream integration with Datadog for real-time monitoring of your AWS infrastructure.

## Overview

The module creates:
- CloudWatch Metric Stream to capture AWS metrics
- Kinesis Firehose to deliver metrics to Datadog
- S3 bucket for backup of failed records
- CloudWatch Log Groups for monitoring delivery
- IAM roles and policies for secure access

## Features

- Real-time metric streaming to Datadog
- Automatic failover to S3 for failed records
- CloudWatch logging for troubleshooting
- Support for multiple AWS namespaces (Lambda, API Gateway, RDS, S3, SQS, EventBridge)
- Configurable log retention

## Prerequisites

1. Datadog account (free tier available)
2. AWS credentials configured
3. Terraform >= 1.0

## Usage

```hcl
module "datadog_integration" {
  source = "../../modules/datadog"

  project_name  = "my-project"
  environment   = "prod"
  datadog_site  = "datadoghq.com"
  log_retention_days = 30

  tags = {
    Environment = "prod"
    Project     = "my-project"
    ManagedBy   = "Terraform"
  }
}
```

## Setup Steps

### 1. Create Datadog Account

Visit https://www.datadoghq.com/free-datadog-trial/ and sign up for free tier.

### 2. Get Your Datadog API Key

1. Log in to Datadog
2. Go to Organization Settings → API Keys
3. Create a new API key
4. Copy the key

### 3. Configure AWS Integration

1. In Datadog, go to Integrations → AWS
2. Click "Add AWS Account"
3. Follow the setup wizard to authorize Datadog

### 4. Deploy the Module

```bash
terraform init
terraform plan
terraform apply
```

### 5. Verify in Datadog

1. Go to Datadog Dashboard
2. Create a new dashboard
3. Add widgets for AWS metrics (Lambda, API Gateway, RDS, etc.)
4. Metrics should appear within 1-2 minutes

## Supported AWS Namespaces

- AWS/Lambda - Lambda function metrics
- AWS/ApiGateway - API Gateway metrics
- AWS/RDS - RDS database metrics
- AWS/S3 - S3 bucket metrics
- AWS/SQS - SQS queue metrics
- AWS/Events - EventBridge metrics

## Datadog Free Tier Limits

- 5 hosts/instances
- 100GB/month data ingestion
- Basic dashboards and alerts
- 15-day data retention

## Costs

- CloudWatch Metric Stream: $0.003 per 1,000 metrics
- Kinesis Firehose: $0.035 per GB ingested
- S3 backup storage: Standard S3 pricing

## Troubleshooting

### Metrics not appearing in Datadog

1. Check CloudWatch Metric Stream status:
```bash
aws cloudwatch describe-metric-streams --names <stream-name>
```

2. Check Firehose delivery status:
```bash
aws firehose describe-delivery-stream --delivery-stream-name <stream-name>
```

3. Check CloudWatch Logs for errors:
```bash
aws logs tail /aws/kinesisfirehose/<environment>-datadog --follow
```

### Failed records in S3

Check the S3 bucket for failed records:
```bash
aws s3 ls s3://<bucket-name>/datadog-failed/
```

## Variables

- `project_name` - Project name for resource naming (required)
- `environment` - Environment name: dev, staging, prod (required)
- `datadog_site` - Datadog site region (default: datadoghq.com)
- `log_retention_days` - CloudWatch log retention (default: 30)
- `tags` - Tags to apply to resources (default: {})

## Outputs

- `metric_stream_arn` - ARN of the CloudWatch Metric Stream
- `firehose_arn` - ARN of the Kinesis Firehose
- `backup_bucket_name` - S3 bucket for failed records
- `metric_stream_name` - Name of the Metric Stream

## Security

- Uses IAM roles with least privilege
- Firehose validates Datadog endpoint
- Failed records backed up to S3
- All logs encrypted at rest

## References

- [Datadog AWS Integration](https://docs.datadoghq.com/integrations/amazon_web_services/)
- [CloudWatch Metric Streams](https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/CloudWatch-Metric-Streams.html)
- [Kinesis Data Firehose](https://docs.aws.amazon.com/kinesis/latest/dev/what-is-this-service.html)
