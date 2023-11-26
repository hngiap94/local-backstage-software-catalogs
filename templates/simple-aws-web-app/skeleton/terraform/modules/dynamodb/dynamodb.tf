resource "aws_dynamodb_table" "helloworld_db" {
  name           = "HelloWorldDatabase"
  billing_mode   = "PROVISIONED"
  hash_key       = "ID"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "ID"
    type = "S"
  }

  tags = {
    Name = "HelloWorldDatabase"
  }
}