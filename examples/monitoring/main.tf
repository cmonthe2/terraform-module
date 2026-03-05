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

# Example: Create CloudWatch monitoring resources
module "monitoring" {
  source = "../../modules/monitoring"

  # Add your monitoring module variables here
  # This is a placeholder - adjust based on your module's actual variables

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}
