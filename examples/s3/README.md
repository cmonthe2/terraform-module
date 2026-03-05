# S3 Example

This example demonstrates how to use the S3 module to create S3 buckets with various configurations.

## Features

- Basic S3 bucket with versioning
- S3 bucket with Lambda event notifications
- Lifecycle rules for object expiration
- Encryption support

## Usage

1. Create a Lambda deployment package:
```bash
# Create a simple Python Lambda handler for S3 events
cat > index.py << 'EOF'
def handler(event, context):
    print(f"Received S3 event: {event}")
    return {'statusCode': 200}
EOF

# Create deployment package
zip lambda_function.zip index.py
```

2. Initialize and apply Terraform:
```bash
terraform init
terraform plan
terraform apply
```

3. Test S3 bucket:
```bash
# Get the bucket name from outputs
BUCKET_NAME=$(terraform output -raw s3_bucket_id)

# Upload a test file
echo "test content" > test.txt
aws s3 cp test.txt s3://$BUCKET_NAME/test.txt

# List bucket contents
aws s3 ls s3://$BUCKET_NAME/
```

## Variables

- `aws_region`: AWS region (default: us-east-1)
- `project_name`: Project name for resource naming (default: example)
- `environment`: Environment name (default: dev)

## Outputs

- `s3_bucket_id`: ID of the basic S3 bucket
- `s3_bucket_arn`: ARN of the basic S3 bucket
- `s3_bucket_with_notifications_id`: ID of the S3 bucket with Lambda notifications
- `s3_bucket_with_notifications_arn`: ARN of the S3 bucket with Lambda notifications

## Cleanup

```bash
terraform destroy
```
