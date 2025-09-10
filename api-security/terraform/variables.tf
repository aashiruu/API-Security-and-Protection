variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
  default     = "LabSecureAPI"
}

variable "stage_name" {
  description = "API deployment stage name"
  type        = string
  default     = "prod"
}

variable "waf_rule_group" {
  description = "WAF rule group name"
  type        = string
  default     = "lab-api-waf"
}
