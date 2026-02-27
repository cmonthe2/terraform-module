variable "project_name"            { 
    description = "The name of the project"
    default     = "default-project"
    type        = string 
     }
variable "environment"             { 
    description = "The environment (e.g., dev, staging, prod)" 
    type = string 
    }
variable "vpc_id"                  { 
    description = "The VPC ID for flow logs" 
    type = string 
    }
variable "flow_log_retention_days" { 
    description = "The number of days to retain flow logs" 
    type = number 
     default = 30 
    }
    