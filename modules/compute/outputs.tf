output "alb_arn"           { 
    value = aws_lb.main.arn 
    description = "ARN of the Application Load Balancer"
}
output "alb_dns_name"      { 
    value = aws_lb.main.dns_name 
    description = "DNS name of the Application Load Balancer"
}
output "bastion_public_ip" { 
    value = aws_instance.bastion.public_ip 
    description = "Public IP address of the bastion host"
}
output "asg_name"          { 
    value = aws_autoscaling_group.app.name 
    description = "Name of the Auto Scaling Group"
}