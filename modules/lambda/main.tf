resource "aws_lambda_function" "this" {
  function_name    = var.function_name
  handler          = var.handler
  runtime          = var.runtime
  role             = aws_iam_role.exec.arn
  filename         = var.zip_path
  source_code_hash = var.source_hash
  memory_size      = var.memory_mb
  timeout          = var.timeout_sec
  layers           = var.layers

  # Only set reserved concurrency if explicitly configured
  reserved_concurrent_executions = var.reserved_concurrency

  environment {
    variables = var.environment_variables
  }

  # Only attach VPC config if provided
  dynamic "vpc_config" {
    for_each = var.vpc_config != null ? [var.vpc_config] : []
    content {
      subnet_ids         = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.basic_logging,
    aws_cloudwatch_log_group.this
  ]

  tags = var.tags
}
