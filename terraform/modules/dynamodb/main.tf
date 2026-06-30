resource "aws_dynamodb_table" "todos" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "userId"
    type = "S"
  }

  global_secondary_index {
    name            = "UserIdIndex"
    projection_type = "ALL"

    # Index Key Schema
    key_schema {
      attribute_name = "userId"
      key_type           = "HASH"
    }
  }

  tags = var.tags
}
