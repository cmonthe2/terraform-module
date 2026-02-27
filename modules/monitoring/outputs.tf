output "flow_log_group_name" {
     description = "The name of the flow log group" 
value = aws_cloudwatch_log_group.flow_logs.name 
}
output "flow_log_id"         { 
     description = "The ID of the flow log" 
value = aws_flow_log.vpc_flow_log.id 
}
