resource "aws_dynamodb_table" "contact_records" {
  name         = "ContactRecords"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "contact_id"

  attribute {
    name = "contact_id"
    type = "S"
  }
}
