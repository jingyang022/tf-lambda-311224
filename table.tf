resource "aws_dynamodb_table" "yap-dynamodb-table" {
    name           = "yap-topmovies"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "year"
    #range_key      = "Genre"

  attribute {
    name = "year"
    type = "N"
  }

  ttl {
    attribute_name = "TimeToExist"
    enabled        = true
  }

  /* global_secondary_index {
    name               = "TitleIndex"
    hash_key           = "Title"
    range_key          = "Author"
    #write_capacity     = 10
    #read_capacity      = 10
    projection_type    = "ALL"
    #non_key_attributes = ["UserId"]
  } */

  tags = {
    Name        = "yap-topmovies"
    Environment = "test"
  }
}