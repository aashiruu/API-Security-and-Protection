# API-Security-and-Protection
To deploy and secure a REST API using AWS API Gateway, Lambda, and Web Application Firewall (WAF) with best security practices.

### Required Tools
- Python 3.8+ (for Lambda function)
- AWS CLI configured
- Terraform installed

### AWS Services Used
- **API Gateway**: Managed API service
- **Lambda**: Serverless compute
- **WAF**: Web Application Firewall
- **CloudWatch**: Logging and monitoring


## Step-by-Step Lab Guide

### Step 1: Explore the Lab Structure
```bash
cd lab2-api-security
ls -la
```

Step 2: Understand the Security Layers

1. WAF Protection Rules:

· AWS Managed Rules for OWASP Top 10
· Rate-based rules to prevent DDoS
· IP reputation rules

2. API Gateway Security:

· API keys for access control
· HTTPS enforcement
· Request validation

3. Lambda Security:

· Least privilege IAM role
· Environment variable encryption
· VPC isolation (optional)

Step 3: Initialize Terraform

```bash
cd terraform
terraform init
```

Expected Output: "Terraform has been successfully initialized!"

Step 4: Review the Security Configuration

```bash
# View the WAF rules
cat waf-rules.tf

# View the API Gateway configuration
cat api-gateway.tf

# View the Lambda function
cat lambda.tf
```

Step 5: Deploy the Secure API

```bash
terraform apply
```

Type yes when prompted.

Expected Output: "Apply complete! Resources: 12 added, 0 changed, 0 destroyed."

Step 6: Test the API Endpoints

Get your API URL and key:

```bash
API_URL=$(terraform output -raw api_url)
API_KEY=$(terraform output -raw api_key)
```

Test legitimate requests:

```bash
# Test GET request (should work)
curl -H "x-api-key: $API_KEY" $API_URL/items

# Test POST request (should work)
curl -X POST -H "x-api-key: $API_KEY" -H "Content-Type: application/json" \
  -d '{"name":"test item","value":100}' $API_URL/items
```

Step 7: Test Security Protections

Test WAF SQL Injection protection:

```bash
# This should be blocked by WAF
curl -H "x-api-key: $API_KEY" "$API_URL/items?param=1' OR '1'='1"
```

Expected: HTTP 403 Forbidden (WAF blocked the request)

Test WAF XSS protection:

```bash
# This should be blocked by WAF
curl -H "x-api-key: $API_KEY" "$API_URL/items?param=<script>alert('xss')</script>"
```

Expected: HTTP 403 Forbidden

Test without API key:

```bash
# This should be blocked by API Gateway
curl $API_URL/items
```

Expected: HTTP 403 Forbidden (Missing API key)

Step 8: Monitor and View Logs

Check WAF metrics:

```bash
# View recent blocked requests
aws wafv2 get-web-acl --name lab-api-waf --scope REGIONAL --region us-east-1
```

Check CloudWatch logs:

```bash
# View API Gateway logs
aws logs describe-log-groups --query 'logGroups[?contains(logGroupName, `LabAPI`)].logGroupName'
```

Step 9: Clean Up

```bash
terraform destroy
```

Type yes when prompted.

Expected Output: "Destroy complete! Resources: 12 destroyed."
