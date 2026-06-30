resource "aws_apigatewayv2_api" "api" {
  name          = "${var.api_name}-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
    allow_headers = ["*"]
    expose_headers = ["*"]
  }

  tags = var.tags
}

# cognito JWT Authorizer
resource "aws_apigatewayv2_authorizer" "cognito" {
  count            = var.cognito_user_pool_id != "" ? 1 : 0
  api_id           = aws_apigatewayv2_api.api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [var.cognito_user_pool_client_id]
    issuer   = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${var.cognito_user_pool_id}"
  }
}

data "aws_region" "current" {}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_invoke_arn
}

resource "aws_apigatewayv2_route" "post_todos" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "POST /todos"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null
}

resource "aws_apigatewayv2_route" "get_todos" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "GET /todos"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null
}

resource "aws_apigatewayv2_route" "get_todo" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "GET /todos/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null
}

resource "aws_apigatewayv2_route" "put_todo" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "PUT /todos/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null
}

resource "aws_apigatewayv2_route" "delete_todo" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "DELETE /todos/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null
}

# root path route for API info
resource "aws_apigatewayv2_route" "root" {
  api_id    = aws_apigatewayv2_api.api.id
  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  tags = var.tags
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
