# Create IAM policy to attach to Lambda execution role to allow access to DynamoDB
resource "aws_iam_policy" "yap_dynamoDB_access" {
    name = "yap-topmovies-api-ddbaccess"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "dynamodb:PutItem",
                    "dynamodb:DeleteItem",
                    "dynamodb:GetItem",
                    "dynamodb:Scan"
                ]
                Effect   = "Allow"
                Resource = aws_dynamodb_table.yap-dynamodb-table.arn
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "yap_dynamoDB_attach" {
  name = "yap_dynamoDB_attach"
  roles = [aws_iam_role.lambda_exec_role.name]
  policy_arn = aws_iam_policy.yap_dynamoDB_access.arn
}

resource "aws_iam_role" "lambda_exec_role" {
 name = "yap-topmovies-api-executionrole"
  assume_role_policy = jsonencode({
   Version = "2012-10-17",
   Statement = [
     {
       Action = "sts:AssumeRole",
       Principal = {
         Service = "lambda.amazonaws.com"
       },
       Effect = "Allow"
     }
   ]
 })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
 role       = aws_iam_role.lambda_exec_role.name
 policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}