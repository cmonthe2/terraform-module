# API Gateway Example

This example demonstrates how to use the API Gateway module to create a REST API with Lambda integration.

## Features

- REST API with multiple routes
- Lambda function integration
- CloudWatch access logging
- CORS configuration
- API throttling settings

## Usage

1. Create a Lambda function deployment package:
```bash
# Create a simple Node.js Lambda handler
mkdir -p lambda
cat > lambda/index.js << 'EOF'
exports.handler = async (event) => {
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Hello from Lambda!' })
  };
};
EOF

# Create deployment package
cd lambda
zip -r ../lambda_function.zip .
cd ..
```

2. Initialize and apply Terraform:
```bash
terraform init
terraform plan
terraform apply
```

3. Test the API:
```bash
# Get the API endpoint from outputs
API_ENDPOINT=$(terraform output -raw api_endpoint)

# Test a route
curl $API_ENDPOINT/health
```

## Variables

- `aws_region`: AWS region (default: us-east-1)
- `project_name`: Project name for resource naming (default: example)
- `environment`: Environment name (default: dev)

## Outputs

- `api_id`: API Gateway REST API ID
- `api_endpoint`: API Gateway endpoint URL
- `stage_name`: API Gateway stage name
- `lambda_function_name`: Lambda function name

## Cleanup

```bash
terraform destroy
```
