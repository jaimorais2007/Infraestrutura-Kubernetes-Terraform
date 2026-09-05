data "terraform_remote_state" "auth" {
  backend = "s3"
  config = {
    bucket = "meu-bucket-terraform-state"
    key    = "auth-service/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_apigatewayv2_api" "main" {
  name          = "oficina-mecanica-auth-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = ["*"]
    allow_methods = ["POST"]
    allow_headers = ["content-type"]
  }
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.main.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_apigatewayv2_integration" "auth" {
  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "AWS_PROXY"
  integration_uri        = data.terraform_remote_state.auth.outputs.authenticate_lambda_invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "auth_route" {
  api_id    = aws_apigatewayv2_api.main.id
  route_key = "POST /authenticate"
  target    = "integrations/${aws_apigatewayv2_integration.auth.id}"
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.auth.outputs.authenticate_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}