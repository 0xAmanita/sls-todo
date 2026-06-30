resource "aws_amplify_app" "frontend" {
  name       = var.app_name
  repository = var.github_repository
  
  # GitHub access token for connecting to repo
  access_token = var.github_token
  
  # Build settings for Vite/React
  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - cd frontend
            - npm ci
        build:
          commands:
            - npm run build
      artifacts:
        baseDirectory: frontend/dist
        files:
          - '**/*'
      cache:
        paths:
          - frontend/node_modules/**/*
  EOT

  # Environment variables for the build
  environment_variables = {
    VITE_API_URL                 = var.api_url
    VITE_USER_POOL_ID            = var.cognito_user_pool_id
    VITE_USER_POOL_CLIENT_ID     = var.cognito_user_pool_client_id
  }

  # Custom rewrite rules for SPA routing
  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  # Auto-deploy on push
  enable_branch_auto_build = true
  enable_branch_auto_deletion = false
  
  # Platform - WEB for frontend apps
  platform = "WEB"
  
  tags = var.tags
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = var.branch_name
  
  enable_auto_build = true
  stage             = "PRODUCTION"
  
  framework = "React"
  
  tags = var.tags
}

# Enable automatic subdomain
resource "aws_amplify_domain_association" "main" {
  count       = var.domain_name != "" ? 1 : 0
  app_id      = aws_amplify_app.frontend.id
  domain_name = var.domain_name
  
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }
  
  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = "www"
  }
}
