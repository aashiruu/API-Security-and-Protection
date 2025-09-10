# Create IAM role for Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lab-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "Lambda-Execution-Role"
  }
}

# IAM policy for Lambda basic execution
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create Lambda function
resource "aws_lambda_function" "api_handler" {
  filename      = "../lambda-function.zip"
  function_name = "lab-api-handler"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"
  timeout       = 30

  environment {
    variables = {
      ENVIRONMENT = "production"
    }
  }

  tags = {
    Name = "API-Handler-Lambda"
  }
}

# Create API Gateway
resource "aws_apigatewayv2_api" "lab_api" {
  name          = var.api_name
  protocol_type = "HTTP"
  description   = "Secure Lab API with WAF protection"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
  }

  tags = {
    Name = "Secure-Lab-API"
  }
}

# Create API stage
resource "aws_apigatewayv2_stage" "prod" {
  api_id      = aws_apigatewayv2_api.lab_api.id
  name        = var.stage_name
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_logs.arn
    format = jsonencode({
      requestId     = "$context.requestId"
      ip            = "$context.identity.sourceIp"
      requestTime   = "$context.requestTime"
      httpMethod    = "$context.httpMethod"
      routeKey      = "$context.routeKey"
      status        = "$context.status"
      protocol      = "$context.protocol"
      responseLength = "$context.responseLength"
      userAgent     = "$context.identity.userAgent"
    })
  }

  tags = {
    Name = "Production-Stage"
  }
}

# Create Lambda integration
resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id           = aws_apigatewayv2_api.lab_api.id
  integration_type = "AWS_PROXY"

  integration_method = "POST"
  integration_uri    = aws_lambda_function.api_handler.invoke_arn
}

# Create route for API
resource "aws_apigatewayv2_route" "api_route" {
  api_id    = aws_apigatewayv2_api.lab_api.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

# Add permission for API Gateway to invoke Lambda
resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.lab_api.execution_arn}/*/*"
}

# Create API key
resource "aws_apigatewayv2_api_key" "lab_key" {
  name = "lab-api-key"
  api_id = aws_apigatewayv2_api.lab_api.id
}

# Create usage plan
resource "aws_apigatewayv2_usage_plan" "lab_plan" {
  name        = "lab-usage-plan"
  api_id      = aws_apigatewayv2_api.lab_api.id
  description = "Usage plan for lab API"

  throttle_settings {
    burst_limit = 10
    rate_limit  = 5
  }

  stage {
    api_id = aws_apigatewayv2_api.lab_api.id
    stage  = aws_apigatewayv2_stage.prod.name
  }

  api_key_selection_expression = "$request.header.x-api-key"
}

# Associate API key with usage plan
resource "aws_apigatewayv2_usage_plan_key" "example" {
  key_id        = aws_apigatewayv2_api_key.lab_key.id
  usage_plan_id = aws_apigatewayv2_usage_plan.lab_plan.id
  key_type      = "API_KEY"
}

# Create CloudWatch log group
resource "aws_cloudwatch_log_group" "api_logs" {
  name              = "/aws/api-gateway/${var.api_name}"
  retention_in_days = 7

  tags = {
    Name = "API-Gateway-Logs"
  }
}
