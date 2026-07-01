module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = local.table_name
  tags       = local.common_tags
}

module "lambda_create_todo" {
  source = "./modules/lambda"

  function_name       = "${local.function_name}-create"
  lambda_zip_path     = "${path.module}/../lambda/build/createTodo.zip"
  table_name          = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  tags                = local.common_tags
}

module "lambda_list_todos" {
  source = "./modules/lambda"

  function_name       = "${local.function_name}-list"
  lambda_zip_path     = "${path.module}/../lambda/build/listTodos.zip"
  table_name          = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  tags                = local.common_tags
}

module "lambda_get_todo" {
  source = "./modules/lambda"

  function_name       = "${local.function_name}-get"
  lambda_zip_path     = "${path.module}/../lambda/build/getTodo.zip"
  table_name          = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  tags                = local.common_tags
}

module "lambda_update_todo" {
  source = "./modules/lambda"

  function_name       = "${local.function_name}-update"
  lambda_zip_path     = "${path.module}/../lambda/build/updateTodo.zip"
  table_name          = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  tags                = local.common_tags
}

module "lambda_delete_todo" {
  source = "./modules/lambda"

  function_name       = "${local.function_name}-delete"
  lambda_zip_path     = "${path.module}/../lambda/build/deleteTodo.zip"
  table_name          = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  tags                = local.common_tags
}

module "api_gateway" {
  source = "./modules/api_gateway"

  api_name                     = "${var.app_name}-${var.environment}"
  
  # Lambda functions
  lambda_create_todo_invoke_arn     = module.lambda_create_todo.invoke_arn
  lambda_create_todo_function_name  = module.lambda_create_todo.function_name
  
  lambda_list_todos_invoke_arn      = module.lambda_list_todos.invoke_arn
  lambda_list_todos_function_name   = module.lambda_list_todos.function_name
  
  lambda_get_todo_invoke_arn        = module.lambda_get_todo.invoke_arn
  lambda_get_todo_function_name     = module.lambda_get_todo.function_name
  
  lambda_update_todo_invoke_arn     = module.lambda_update_todo.invoke_arn
  lambda_update_todo_function_name  = module.lambda_update_todo.function_name
  
  lambda_delete_todo_invoke_arn     = module.lambda_delete_todo.invoke_arn
  lambda_delete_todo_function_name  = module.lambda_delete_todo.function_name
  
  cognito_user_pool_id         = module.cognito.user_pool_id
  cognito_user_pool_client_id  = module.cognito.user_pool_client_id
  tags                         = local.common_tags
}

module "cognito" {
  source = "./modules/cognito"

  pool_name = "${var.app_name}-${var.environment}"
  tags      = local.common_tags
}

module "s3_cloudfront" {
  source = "./modules/s3_cloudfront"

  bucket_name = "${var.app_name}-${var.environment}-frontend"
  price_class = "PriceClass_100"
  tags        = local.common_tags
}
