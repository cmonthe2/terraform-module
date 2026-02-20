variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
}

variable "cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "cidr_block must be a valid IPv4 CIDR"
  }
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to deploy subnets into"

  validation {
    condition     = length(var.availability_zones) >= 2
    error_message = "At least 2 availability zones are required for high availability"
  }
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets — one per AZ"

  validation {
    condition     = length(var.public_subnet_cidrs) == length(var.availability_zones)
    error_message = "Must provide one public subnet CIDR per availability zone"
  }
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets — one per AZ"

  validation {
    condition     = length(var.private_subnet_cidrs) == length(var.availability_zones)
    error_message = "Must provide one private subnet CIDR per availability zone"
  }
}

variable "enable_nat_gateway" {
  type        = bool
  description = "Create NAT Gateways so private subnets can reach the internet"
  default     = true
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use a single NAT Gateway instead of one per AZ. Cheaper but not HA"
  default     = false
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in the VPC — required for some AWS services"
  default     = true
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in the VPC"
  default     = true
}

variable "enable_flow_logs" {
  type        = bool
  description = "Enable VPC Flow Logs to CloudWatch"
  default     = true
}

variable "flow_log_retention_days" {
  type        = number
  description = "CloudWatch log retention for flow logs"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}