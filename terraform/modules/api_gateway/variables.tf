variable "api_name" {
  description = "API Gateway name"
  type        = string
}

# Lambda function for creating todos
variable "lambda_create_todo_invoke_arn" {
  description = "Create Todo Lambda invoke ARN"
  type        = string
}

variable "lambda_create_todo_function_name" {
  description = "Create Todo Lambda function name"
  type        = string
}

# Lambda function for listing todos
variable "lambda_list_todos_invoke_arn" {
  description = "List Todos Lambda invoke ARN"
  type        = string
}

variable "lambda_list_todos_function_name" {
  description = "List Todos Lambda function name"
  type        = string
}

# Lambda function for getting a single todo
variable "lambda_get_todo_invoke_arn" {
  description = "Get Todo Lambda invoke ARN"
  type        = string
}

variable "lambda_get_todo_function_name" {
  description = "Get Todo Lambda function name"
  type        = string
}

# Lambda function for updating a todo
variable "lambda_update_todo_invoke_arn" {
  description = "Update Todo Lambda invoke ARN"
  type        = string
}

variable "lambda_update_todo_function_name" {
  description = "Update Todo Lambda function name"
  type        = string
}

# Lambda function for deleting a todo
variable "lambda_delete_todo_invoke_arn" {
  description = "Delete Todo Lambda invoke ARN"
  type        = string
}

variable "lambda_delete_todo_function_name" {
  description = "Delete Todo Lambda function name"
  type        = string
}

variable "cognito_user_pool_id" {
  description = "Cognito User Pool ID for JWT authorizer"
  type        = string
  default     = ""
}

variable "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
