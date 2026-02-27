locals {
  # Build a map of unique resource paths from the routes list
  # e.g. ["/orders", "/orders/{order_id}"]
  unique_paths = distinct([for r in var.routes : r.path])

  # Split each path into segments to build the resource tree
  # /orders/{order_id} → ["orders", "{order_id}"]
  path_segments = {
    for path in local.unique_paths :
    path => [for s in split("/", path) : s if s != ""]
  }
}

# ── REST API ──────────────────────────────────────────────────────────────────
resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.description

  endpoint_configuration {
    types = [var.endpoint_type]
  }

  tags = var.tags
}

# ── Resources (paths) ─────────────────────────────────────────────────────────
# Build a flat map of path → resource for all unique paths
resource "aws_api_gateway_resource" "this" {
  for_each = {
    for path in local.unique_paths :
    path => path
  }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id

  # Last segment of the path is the path_part
  # e.g. /orders/{order_id} → {order_id}
  path_part = local.path_segments[each.key][length(local.path_segments[each.key]) - 1]
}

# ── Methods ───────────────────────────────────────────────────────────────────
resource "aws_api_gateway_method" "this" {
  for_each = {
    for r in var.routes :
    "${r.method}:${r.path}" => r
  }

  rest_api_id      = aws_api_gateway_rest_api.this.id
  resource_id      = aws_api_gateway_resource.this[each.value.path].id
  http_method      = each.value.method
  authorization    = each.value.authorization
  authorizer_id    = each.value.authorizer_id
  api_key_required = each.value.api_key_required
}

# ── Lambda Proxy Integrations ─────────────────────────────────────────────────
resource "aws_api_gateway_integration" "this" {
  for_each = {
    for r in var.routes :
    "${r.method}:${r.path}" => r
  }

  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.this[each.value.path].id
  http_method             = aws_api_gateway_method.this[each.key].http_method
  integration_http_method = "POST" # always POST when invoking Lambda
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

# ── CORS OPTIONS method ───────────────────────────────────────────────────────
resource "aws_api_gateway_method" "options" {
  for_each = length(var.cors_origins) > 0 ? {
    for path in local.unique_paths : path => path
  } : {}

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options" {
  for_each = length(var.cors_origins) > 0 ? {
    for path in local.unique_paths : path => path
  } : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options" {
  for_each = length(var.cors_origins) > 0 ? {
    for path in local.unique_paths : path => path
  } : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options" {
  for_each = length(var.cors_origins) > 0 ? {
    for path in local.unique_paths : path => path
  } : {}

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this[each.key].id
  http_method = aws_api_gateway_method.options[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization,X-Api-Key'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,PATCH,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'${join(",", var.cors_origins)}'"
  }

  depends_on = [aws_api_gateway_integration.options]
}

# ── Deployment ────────────────────────────────────────────────────────────────
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # Redeploy when any method or integration changes
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_method.this,
      aws_api_gateway_integration.this,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_integration.this]
}

# ── Stage ─────────────────────────────────────────────────────────────────────
resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.environment

  dynamic "access_log_settings" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.this[0].arn
      format = jsonencode({
        requestId      = "$context.requestId"
        ip             = "$context.identity.sourceIp"
        caller         = "$context.identity.caller"
        user           = "$context.identity.user"
        requestTime    = "$context.requestTime"
        httpMethod     = "$context.httpMethod"
        resourcePath   = "$context.resourcePath"
        status         = "$context.status"
        protocol       = "$context.protocol"
        responseLength = "$context.responseLength"
      })
    }
  }

  # Throttling is configured via aws_api_gateway_method_settings resource below
  tags = var.tags
}

# ── CloudWatch Log Group ──────────────────────────────────────────────────────
resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_access_logs ? 1 : 0
  name              = "/aws/apigateway/${var.api_name}/${var.environment}"
  retention_in_days = var.log_retention_days
  tags              = var.tags
}

# ── Method Settings (stage-level throttling) ──────────────────────────────────
resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*" # top-level, not inside settings block

  settings {
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit
  }

  depends_on = [aws_api_gateway_stage.this]
}
# ── API Key + Usage Plan (optional) ──────────────────────────────────────────
resource "aws_api_gateway_api_key" "this" {
  count = var.enable_api_key ? 1 : 0
  name  = "${var.api_name}-${var.environment}-key"
  tags  = var.tags
}

resource "aws_api_gateway_usage_plan" "this" {
  count = var.enable_api_key ? 1 : 0
  name  = "${var.api_name}-${var.environment}-usage-plan"

  api_stages {
    api_id = aws_api_gateway_rest_api.this.id
    stage  = aws_api_gateway_stage.this.stage_name
  }

  throttle_settings {
    burst_limit = var.throttling_burst_limit
    rate_limit  = var.throttling_rate_limit
  }

  tags = var.tags
}

resource "aws_api_gateway_usage_plan_key" "this" {
  count         = var.enable_api_key ? 1 : 0
  key_id        = aws_api_gateway_api_key.this[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.this[0].id
}
