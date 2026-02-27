locals {
  # FIFO queues must end in .fifo
  queue_name = var.fifo_queue ? "${var.queue_name}.fifo" : var.queue_name
  dlq_name   = var.fifo_queue ? "${var.queue_name}-dlq.fifo" : "${var.queue_name}-dlq"
}

# ── Dead Letter Queue ─────────────────────────────────────────────────────────
resource "aws_sqs_queue" "dlq" {
  name                      = local.dlq_name
  fifo_queue                = var.fifo_queue
  message_retention_seconds = 1209600 # 14 days — max, gives you time to investigate
  kms_master_key_id         = var.kms_key_arn

  tags = merge(var.tags, { Name = local.dlq_name, Type = "dlq" })
}

# ── Main Queue ────────────────────────────────────────────────────────────────
resource "aws_sqs_queue" "this" {
  name                        = local.queue_name
  fifo_queue                  = var.fifo_queue
  content_based_deduplication = var.fifo_queue ? var.content_based_deduplication : null
  visibility_timeout_seconds  = var.visibility_timeout_seconds
  message_retention_seconds   = var.message_retention_seconds
  kms_master_key_id           = var.kms_key_arn

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(var.tags, { Name = local.queue_name, Type = "main" })
}

# ── Queue Policy — allow the Lambda role to read ──────────────────────────────
resource "aws_sqs_queue_policy" "this" {
  queue_url = aws_sqs_queue.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowLambdaConsume"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::*:role/${var.lambda_role_name}"
        }
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.this.arn
      }
    ]
  })
}

# ── IAM — attach SQS permissions to the Lambda execution role ─────────────────
resource "aws_iam_role_policy" "sqs_consume" {
  name = "${var.lambda_function_name}-sqs-consume"
  role = var.lambda_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "SQSConsume"
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ChangeMessageVisibility"
        ]
        Resource = aws_sqs_queue.this.arn
      },
      {
        Sid      = "SQSDLQSendMessage"
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = aws_sqs_queue.dlq.arn
      }
    ]
  })
}

# ── Event Source Mapping — wires SQS to Lambda ────────────────────────────────
resource "aws_lambda_event_source_mapping" "this" {
  event_source_arn                   = aws_sqs_queue.this.arn
  function_name                      = var.lambda_function_arn
  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.maximum_batching_window_seconds
  enabled                            = true

  # Critical — enables partial batch failure reporting
  # Without this, any failure in the batch retries ALL messages
  function_response_types = ["ReportBatchItemFailures"]

  scaling_config {
    maximum_concurrency = 10 # cap concurrent Lambda invocations from this queue
  }
}
