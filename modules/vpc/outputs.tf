output "vpc_id" {
  value       = aws_vpc.this.id
  description = "The ID of the VPC"
}
output "vpc_cidr" {
  value       = aws_vpc.this.cidr_block
  description = "The CIDR block of the VPC"
}
output "public_subnet_ids" {
  value       = aws_subnet.public[*].id
  description = "List of IDs for the public subnets"
}
output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "List of IDs for the private subnets"
}
output "lambda_sg_id" {
  value       = aws_security_group.lambda.id
  description = "ID of the security group for Lambda functions"
}
output "nat_gateway_ids" {
  value       = aws_nat_gateway.this[*].id
  description = "List of IDs for the NAT Gateways (if enabled)"
}
output "internet_gateway_id" {
  value       = aws_internet_gateway.this.id
  description = "ID of the Internet Gateway"
}
output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "ID of the public route table"
}
output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "List of IDs for the private route tables"
}  