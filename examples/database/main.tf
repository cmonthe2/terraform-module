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

# Example: Create RDS database instance
module "database" {
  source = "../../modules/database"

  project_name          = var.project_name
  environment           = var.environment
  db_instance_class     = "db.t3.micro"
  db_allocated_storage  = 20
  db_name               = "exampledb"
  db_username           = "admin"
  db_password           = var.db_password
  private_db_subnet_ids = var.private_subnet_ids
  db_sg_id              = aws_security_group.db_sg.id

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Security group for database
resource "aws_security_group" "db_sg" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for RDS database"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}
