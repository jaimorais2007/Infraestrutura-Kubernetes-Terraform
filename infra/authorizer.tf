# Lambda Authorizer que valida o JWT emitido por POST /authenticate nas demais rotas do
# API Gateway. O token e assinado com HS256/segredo simetrico (ver
# Lambda-Function-Serverless/authorizer.js), por isso precisa ser um authorizer REQUEST
# customizado - o authorizer nativo "JWT" do API Gateway HTTP API so valida RS256 via JWKS.
resource "aws_apigatewayv2_authorizer" "jwt" {
  api_id                            = aws_apigatewayv2_api.main.id
  authorizer_type                   = "REQUEST"
  name                              = "jwt-authorizer"
  authorizer_uri                    = data.terraform_remote_state.auth.outputs.authorizer_lambda_invoke_arn
  authorizer_payload_format_version = "2.0"
  enable_simple_responses           = true
  identity_sources                  = ["$request.header.Authorization"]

  # Sem cache: os tokens desta aplicacao podem expirar em poucos minutos
  # (var.jwt_expires_in), entao um resultado em cache poderia aceitar um token ja expirado.
  authorizer_result_ttl_in_seconds = 0
}

resource "aws_lambda_permission" "allow_apigw_authorizer" {
  statement_id  = "AllowAPIGatewayInvokeAuthorizer"
  action        = "lambda:InvokeFunction"
  function_name = data.terraform_remote_state.auth.outputs.authorizer_lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/authorizers/${aws_apigatewayv2_authorizer.jwt.id}"
}
