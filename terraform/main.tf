module "dynamodb" {
  source = "./modules/dynamodb"

  table_name = local.table_name
  tags       = local.common_tags
}

module "lambda" {
  source = "./modules/lambda"

  function_name       = local.function_name
  lambda_zip_path     = "${path.module}/../lambda/build/function.zip"
  table_name          = module.dynamodb.table_name
  dynamodb_table_arn  = module.dynamodb.table_arn
  tags                = local.common_tags
}

module "api_gateway" {
  source = "./modules/api_gateway"

  api_name             = "${var.app_name}-${var.environment}"
  lambda_invoke_arn    = module.lambda.invoke_arn
  lambda_function_name = module.lambda.function_name
  tags                 = local.common_tags
}

module "cognito" {
  source = "./modules/cognito"

  pool_name = "${var.app_name}-${var.environment}"
  tags      = local.common_tags
}

module "s3" {
  source = "./modules/s3"

  bucket_name = local.bucket_name
  tags        = local.common_tags
}
