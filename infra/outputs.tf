output "kubeconfig_path" {
  description = "Caminho do kubeconfig para usar com kubectl"
  value       = var.kubeconfig_path
}

output "auth_api_invoke_url" {
  description = "URL para invocar POST /authenticate na Lambda de autenticação"
  value       = "${aws_apigatewayv2_stage.default.invoke_url}/authenticate"
}
