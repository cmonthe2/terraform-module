# Lambda Example

This example demonstrates how to use the Lambda module to create Lambda functions with various configurations.

## Features

- Simple Lambda function
- Lambda function with VPC access
- Environment variables
- CloudWatch logging
- Reserved concurrency

## Usage

1. Create a Lambda deployment package:
```bash
# Create a simple Python Lambda handler
cat > lambda_function.py << 'EOF'
def handler(event, context):
    return {
        'statusCode': 200,
        'body': 'Hello from Lambda!'
    }
EOF

# Create deployment package
zip lambda_function.zip lambda_function.py
```

2. Initialize and apply Terraform:
```bash
terraform init
terraform plan
terraform apply
```

3. Invoke the Lambda function:
```bash
# Get the function name from outputs
FUNCTION_NAME=$(terraform output -raw lambda_function_name)

# Invoke the function
aws lambda invoke --function-name $FUNCTION_NAME response.json
cat response.json
```

## Variables

- `aws_region`: AWS region (default: us-east-1)
- `project_name`: Project name for resource naming (default: example)
- `environment`: Environment name (default: dev)
- `private_subnet_ids`: Private subnet IDs for VPC access (optional)
- `vpc_id`: VPC ID for security group (optional)
- `db_host`: Database host for environment variables (optional)

## Outputs

- `lambda_function_arn`: ARN of the basic Lambda function
- `lambda_function_name`: Name of the basic Lambda function
- `lambda_with_vpc_arn`: ARN of the Lambda function with VPC access
- `lambda_with_vpc_name`: Name of the Lambda function with VPC access

## Cleanup

```bash
terraform destroy
```
