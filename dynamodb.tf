resource "aws_dynamodb_table" "ecri_audit_table" {
  name           = var.dynamodb_ecri_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "notification_date"
  range_key      = "account_number"

  attribute {
    name = "notification_date"
    type = "S"
  }

  attribute {
    name = "account_number"
    type = "S"
  }
}