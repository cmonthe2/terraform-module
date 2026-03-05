terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Example: Set up Datadog integration for real-time monitoring
module "datadog_integration" {
  source = "../../modules/datadog"

  project_name       = var.project_name
  environment        = var.environment
  datadog_site       = var.datadog_site
  log_retention_days = 30

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Output the metric stream name for verification
output "metric_stream_name" {
  value       = module.datadog_integration.metric_stream_name
  description = "CloudWatch Metric Stream name - verify this is active in AWS Console"
}

output "setup_instructions" {
  value       = <<-EOT
    Datadog Integration Setup Complete!
    
    Next steps:
    1. Sign up for Datadog free tier: https://www.datadoghq.com/free-datadog-trial/
    2. Get your API key from: Organization Settings → API Keys
    3. In Datadog, go to Integrations → AWS
    4. Authorize the AWS account
    5. Create a dashboard to visualize metrics
    
    Metrics will appear in Datadog within 1-2 minutes.
    
    Metric Stream Name: ${module.datadog_integration.metric_stream_name}
    Backup Bucket: ${module.datadog_integration.backup_bucket_name}
  EOT
  description = "Setup instructions for Datadog integration"
}
