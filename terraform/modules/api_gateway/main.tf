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

# Cognito JWT Authorizer
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

# Lambda Integrations - one per function
resource "aws_apigatewayv2_integration" "create_todo" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_create_todo_invoke_arn

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_integration" "list_todos" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_list_todos_invoke_arn

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_integration" "get_todo" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_get_todo_invoke_arn

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_integration" "update_todo" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_update_todo_invoke_arn

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_apigatewayv2_integration" "delete_todo" {
  api_id           = aws_apigatewayv2_api.api.id
  integration_type = "AWS_PROXY"
  integration_uri  = var.lambda_delete_todo_invoke_arn

  lifecycle {
    create_before_destroy = true
  }
}

# Routes - each route points to its specific Lambda integration
resource "aws_apigatewayv2_route" "post_todos" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "POST /todos"
  target             = "integrations/${aws_apigatewayv2_integration.create_todo.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null

  depends_on = [aws_apigatewayv2_integration.create_todo]
}

resource "aws_apigatewayv2_route" "get_todos" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "GET /todos"
  target             = "integrations/${aws_apigatewayv2_integration.list_todos.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null

  depends_on = [aws_apigatewayv2_integration.list_todos]
}

resource "aws_apigatewayv2_route" "get_todo" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "GET /todos/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.get_todo.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null

  depends_on = [aws_apigatewayv2_integration.get_todo]
}

resource "aws_apigatewayv2_route" "put_todo" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "PUT /todos/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.update_todo.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null

  depends_on = [aws_apigatewayv2_integration.update_todo]
}

resource "aws_apigatewayv2_route" "delete_todo" {
  api_id             = aws_apigatewayv2_api.api.id
  route_key          = "DELETE /todos/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.delete_todo.id}"
  authorization_type = var.cognito_user_pool_id != "" ? "JWT" : "NONE"
  authorizer_id      = var.cognito_user_pool_id != "" ? aws_apigatewayv2_authorizer.cognito[0].id : null

  depends_on = [aws_apigatewayv2_integration.delete_todo]
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.api.id
  name        = "$default"
  auto_deploy = true

  tags = var.tags

  depends_on = [
    aws_apigatewayv2_route.post_todos,
    aws_apigatewayv2_route.get_todos,
    aws_apigatewayv2_route.get_todo,
    aws_apigatewayv2_route.put_todo,
    aws_apigatewayv2_route.delete_todo
  ]
}

# Lambda Permissions - one per function
resource "aws_lambda_permission" "create_todo" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_create_todo_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "list_todos" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_list_todos_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "get_todo" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_get_todo_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "update_todo" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_update_todo_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "delete_todo" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_delete_todo_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.api.execution_arn}/*/*"
}
