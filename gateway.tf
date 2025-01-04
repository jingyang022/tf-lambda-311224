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

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
  depends_on = [aws_cloudwatch_log_group.api_gw_logs]
}

resource "aws_apigatewayv2_integration" "api_integration" {
  api_id = aws_apigatewayv2_api.yap_api.id
  integration_type = "AWS_PROXY"
  integration_method = "POST"
  payload_format_version = "2.0"

  integration_uri    = aws_lambda_function.func.invoke_arn
}

resource "aws_apigatewayv2_route" "put_topmovies" {
  api_id = aws_apigatewayv2_api.yap_api.id

  route_key = "PUT /topmovies"
  target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}

resource "aws_apigatewayv2_route" "get_topmovies" {
  api_id = aws_apigatewayv2_api.yap_api.id

  route_key = "GET /topmovies"
  target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}

resource "aws_apigatewayv2_route" "get_topmovies_by_year" {
  api_id = aws_apigatewayv2_api.yap_api.id

  route_key = "GET /topmovies/{year}"
  target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}

resource "aws_apigatewayv2_route" "delete_topmovies_by_year" {
  api_id = aws_apigatewayv2_api.yap_api.id

  route_key = "DELETE /topmovies/{year}"
  target    = "integrations/${aws_apigatewayv2_integration.api_integration.id}"
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.func.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.yap_api.execution_arn}/*/*"
}

# aws_cloudwatch_log_group to get the logs of the API Gateway execution.
resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name              = "/aws/api_gw_logs/${aws_apigatewayv2_api.yap_api.name}"
  retention_in_days = 7
}

# Setup custom domain name for API Gateway endpoint
resource "aws_api_gateway_domain_name" "api_gw_domain" {
  domain_name              = "yap201224.sctp-sandbox.com"
  regional_certificate_arn = aws_acm_certificate_validation.cert_validation.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_route53_record" "api_gw_record" {
  name    = aws_api_gateway_domain_name.api_gw_domain.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.sctp_zone.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.api_gw_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_gw_domain.regional_zone_id
  }
}

/* resource "aws_api_gateway_base_path_mapping" "api_gw_domain_mapping" {
  api_id = "${aws_apigatewayv2_api.yap_api.id}"
  stage_name  = "${aws_apigatewayv2_stage.lambda-stage.stage_name}"
  domain_name = "${aws_api_gateway_domain_name.api_gw_domain.domain_name}"
} */
