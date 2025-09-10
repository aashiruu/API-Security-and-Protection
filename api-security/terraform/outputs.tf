```hcl
output "api_url" {
  description = "URL of the deployed API"
  value       = aws_apigatewayv2_stage.prod.invoke_url
}

output "api_key" {
  description = "API key for accessing the endpoint"
  value       = aws_apigatewayv2_api_key.lab_key.value
  sensitive   = true
}

output "waf_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.lab_waf.arn
}

output "lambda_function_name" {
  description = "Name of the Lambda function"
  value       = aws_lambda_function.api_handler.function_name
}
```
