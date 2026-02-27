variable "project_name" {
  description = "Name of the project, used for tagging and naming resources"
  type        = string

}
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string

}
variable "vpc_id" {
  description = "ID of the VPC to deploy security groups into"
  type        = string

}
# variable "vpc_cidr" {
#   description = "CIDR block of the VPC"
#   type        = string

# }
