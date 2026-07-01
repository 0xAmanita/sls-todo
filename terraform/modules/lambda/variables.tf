variable "function_name" {
  description = "Lambda function name"
  type        = string
}

variable "handler" {
  description = "Lambda handler (default: <filename>.handler)"
  type        = string
  default     = ""
}

variable "lambda_zip_path" {
  description = "Path to Lambda deployment zip"
  type        = string
}

variable "table_name" {
  description = "DynamoDB table name"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "DynamoDB table ARN"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
