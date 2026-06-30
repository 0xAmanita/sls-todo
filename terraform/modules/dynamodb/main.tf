resource "aws_dynamodb_table" "todos" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  global_secondary_index {
    name = "UserIdIndex"
    hash_key = "userId"
    projection_type = "ALL"
  }

  tags = var.tags
}
