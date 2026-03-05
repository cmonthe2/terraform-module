output "db_instance_endpoint" {
  description = "RDS instance endpoint"
  value       = module.database.db_instance_endpoint
}

output "db_instance_id" {
  description = "RDS instance ID"
  value       = module.database.db_instance_id
}
