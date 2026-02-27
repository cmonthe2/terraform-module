variable "project_name" {
  description = "Name of the project, used for tagging and naming resources"
  type        = string
}
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}
variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}
variable "rate_limit_per_ip" {
  description = "Rate limit per IP address"
  type        = number
}
