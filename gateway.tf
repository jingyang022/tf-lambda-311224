#############################################################
# HTTP API
#############################################################

resource "aws_apigatewayv2_api" "yap_api" {
  name          = "yap-topmovies-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "lambda-stage" {
  api_id = aws_apigatewayv2_api.yap_api.id
  name   = "$default"

  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "api_integration" {
  api_id = aws_apigatewayv2_api.yap_api.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"

  integration_uri    = aws_lambda_function.func.invoke_arn
}

resource "aws_apigatewayv2_route" "api_route1" {
  api_id = aws_apigatewayv2_api.yap_api.id

  route_key = "GET /topmovies"
  target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}

resource "aws_apigatewayv2_route" "api_route2" {
  api_id = aws_apigatewayv2_api.yap_api.id

  route_key = "GET /topmovies/{year}"
  target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}

resource "aws_apigatewayv2_route" "api_route3" {
  api_id = aws_apigatewayv2_api.yap_api.id

  route_key = "PUT /topmovies"
  target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.yap_api.execution_arn}/*/*/topmovies"
}
