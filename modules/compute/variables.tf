variable "project_name" {
  description = "value"
  type        = string
}
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}
variable "private_app_subnet_ids" {
  description = "List of private app subnet IDs"
  type        = list(string)
}
variable "bastion_sg_id" {
  description = "ID of the bastion security group"
  type        = string
}
variable "alb_sg_id" {
  description = "ID of the ALB security group"
  type        = string
}
variable "app_sg_id" {
  description = "ID of the app security group"
  type        = string
}
variable "instance_type" {
  description = "Instance type for app instances"
  type        = string
}
variable "bastion_instance_type" {
  description = "Instance type for bastion host"
  type        = string
}
variable "key_pair_name" {
  description = "Name of the SSH key pair"
  type        = string
}
variable "asg_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
}
variable "asg_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
}
variable "asg_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
}
