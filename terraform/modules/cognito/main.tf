resource "aws_cognito_user_pool" "pool" {
  name = "${var.pool_name}-user-pool"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  # user attributes for profile information
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = true
    required            = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "given_name"
    attribute_data_type = "String"
    mutable             = true
    required            = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    name                = "family_name"
    attribute_data_type = "String"
    mutable             = true
    required            = false

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  password_policy {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  tags = var.tags
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "${var.pool_name}-client"
  user_pool_id = aws_cognito_user_pool.pool.id

  explicit_auth_flows = [
    # for amplify signin
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    # token refresh
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  generate_secret = false
}
