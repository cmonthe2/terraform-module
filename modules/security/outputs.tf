output "bastion_sg_id" { 
    value = aws_security_group.bastion.id 
    description = "ID of the security group for the bastion host"
    }
output "alb_sg_id"     {
    value = aws_security_group.alb.id 
    description = "ID of the security group for the ALB"
    }
output "app_sg_id"     { 
  value = aws_security_group.app.id 
  description = "ID of the security group for the application tier"
  }
output "db_sg_id"      { 
  value = aws_security_group.db.id 
  description = "ID of the security group for the database tier"
  }