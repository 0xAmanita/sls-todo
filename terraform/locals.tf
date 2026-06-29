locals {
  function_name = "${var.app_name}-${var.environment}-lambda"
  table_name    = "${var.app_name}-${var.environment}-table"
  bucket_name   = "${var.app_name}-${var.environment}-frontend"
  
  common_tags = {
    Application = var.app_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
