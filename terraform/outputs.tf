output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "cognito_user_pool_id" {
  description = "Cognito User Pool ID"
  value       = module.cognito.user_pool_id
}

output "cognito_user_pool_client_id" {
  description = "Cognito User Pool Client ID"
  value       = module.cognito.user_pool_client_id
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket hosting the frontend"
  value       = module.s3_cloudfront.bucket_name
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution"
  value       = module.s3_cloudfront.cloudfront_distribution_id
}

output "cloudfront_url" {
  description = "URL of the CloudFront distribution"
  value       = module.s3_cloudfront.cloudfront_url
}

output "cloudfront_domain_name" {
  description = "Domain name of the CloudFront distribution"
  value       = module.s3_cloudfront.cloudfront_domain_name
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.dynamodb.table_name
}

output "lambda_function_name" {
  description = "Lambda function name (create todo)"
  value       = module.lambda_create_todo.function_name
}

output "lambda_function_names" {
  description = "All Lambda function names"
  value = {
    create_todo = module.lambda_create_todo.function_name
    list_todos  = module.lambda_list_todos.function_name
    get_todo    = module.lambda_get_todo.function_name
    update_todo = module.lambda_update_todo.function_name
    delete_todo = module.lambda_delete_todo.function_name
  }
}
