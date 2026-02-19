variable "rule_name"            {
     type = string 
     }
variable "description"          { 
    type = string   
    }
variable "schedule_expression"  { 
    type = string 
    }   # e.g. "rate(1 hour)" or "cron(0 2 * * ? *)"
variable "enabled"              { 
    type = bool    
    }
variable "lambda_arn"           { 
    type = string 
    }
variable "lambda_function_name" {
     type = string 
     }

