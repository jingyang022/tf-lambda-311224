output "table_arn" {
  value = aws_dynamodb_table.yap-dynamodb-table.arn
}

output "invoke_url" {
  description = "Invoke URL for API Gateway stage."

  value = aws_apigatewayv2_stage.lambda-stage.invoke_url
}
