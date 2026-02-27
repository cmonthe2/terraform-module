variable "project_name" {
  description = "The name of the project"
  default     = "default-project"
  type        = string
}
variable "environment" {
  description = "The environment (e.g., dev, staging, prod)"
  type        = string
}
variable "private_db_subnet_ids" {
  description = "List of private subnet IDs for the database"
  type        = list(string)
}
variable "db_sg_id" {
  description = "The security group ID for the database"
  type        = string
}
variable "db_name" {
  description = "The name of the database"
  type        = string
}
variable "db_username" {
  description = "The username for the database"
  type        = string
}
variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}
variable "db_instance_class" {
  description = "The instance class for the database"
  type        = string
}
variable "db_allocated_storage" {
  description = "The allocated storage for the database (in GB)"
  type        = number
}
