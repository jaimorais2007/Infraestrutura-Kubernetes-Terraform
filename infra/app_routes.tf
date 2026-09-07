# Expõe, através do mesmo API Gateway HTTP, as rotas da aplicação principal
# (Aplicacao-principal-executando-em-Kubernetes/src/OficinaApi.Presentation/Controllers),
# que roda no k3s atrás de um Service type=LoadBalancer (k3s ServiceLB expõe a porta 80
# diretamente no IP público do EC2 - ver k8s/service.yaml naquele repositório).
#
# Cada rota usa uma integração HTTP_PROXY própria porque o caminho de destino muda por
# rota (parâmetros como {id} são repassados automaticamente quando o nome do parâmetro é
# igual na rota e na integration_uri).
locals {
  app_routes = {
    auth_login = { method = "POST", path = "/api/auth/login" }

    customers_list             = { method = "GET", path = "/api/Customer" }
    customers_get              = { method = "GET", path = "/api/Customer/{id}" }
    customers_create           = { method = "POST", path = "/api/Customer" }
    customers_update           = { method = "PUT", path = "/api/Customer/{id}" }
    customers_logical_deletion = { method = "PUT", path = "/api/Customer/{id}/LogicalDeletion" }
    customers_delete           = { method = "DELETE", path = "/api/Customer/{id}" }

    parts_list             = { method = "GET", path = "/api/Parts" }
    parts_get              = { method = "GET", path = "/api/Parts/{id}" }
    parts_create           = { method = "POST", path = "/api/Parts" }
    parts_add_stock        = { method = "POST", path = "/api/Parts/{id}/add-stock" }
    parts_remove_stock     = { method = "POST", path = "/api/Parts/{id}/remove-stock" }
    parts_logical_deletion = { method = "PUT", path = "/api/Parts/{id}/LogicalDeletion" }
    parts_delete           = { method = "DELETE", path = "/api/Parts/{id}" }

    services_list             = { method = "GET", path = "/api/Service" }
    services_get              = { method = "GET", path = "/api/Service/{id}" }
    services_create           = { method = "POST", path = "/api/Service" }
    services_update           = { method = "PUT", path = "/api/Service/{id}" }
    services_logical_deletion = { method = "PUT", path = "/api/Service/{id}/LogicalDeletion" }
    services_delete           = { method = "DELETE", path = "/api/Service/{id}" }

    service_orders_list             = { method = "GET", path = "/api/ServiceOrders" }
    service_orders_get              = { method = "GET", path = "/api/ServiceOrders/{id}" }
    service_orders_status           = { method = "GET", path = "/api/ServiceOrders/{id}/status" }
    service_orders_create           = { method = "POST", path = "/api/ServiceOrders" }
    service_orders_start_analysis   = { method = "POST", path = "/api/ServiceOrders/{id}/start-analysis" }
    service_orders_finish_analysis  = { method = "POST", path = "/api/ServiceOrders/{id}/finish-analysis" }
    service_orders_add_part         = { method = "POST", path = "/api/ServiceOrders/{id}/parts" }
    service_orders_add_service      = { method = "POST", path = "/api/ServiceOrders/{id}/services" }
    service_orders_approve          = { method = "POST", path = "/api/ServiceOrders/{id}/approve" }
    service_orders_finish_execution = { method = "POST", path = "/api/ServiceOrders/{id}/finish-execution" }
    service_orders_deliver          = { method = "POST", path = "/api/ServiceOrders/{id}/deliver" }
    service_orders_refuse           = { method = "POST", path = "/api/ServiceOrders/{id}/refuse" }
    service_orders_pending_stocks   = { method = "GET", path = "/api/ServiceOrders/{id}/pending-stocks" }
    service_orders_average_duration = { method = "GET", path = "/api/ServiceOrders/average-duration" }

    users_list             = { method = "GET", path = "/api/Users" }
    users_get              = { method = "GET", path = "/api/Users/{id}" }
    users_create           = { method = "POST", path = "/api/Users" }
    users_update           = { method = "PUT", path = "/api/Users/{id}" }
    users_logical_deletion = { method = "PUT", path = "/api/Users/{id}/LogicalDeletion" }
    users_delete           = { method = "DELETE", path = "/api/Users/{id}" }

    vehicles_list             = { method = "GET", path = "/api/Vehicle" }
    vehicles_get              = { method = "GET", path = "/api/Vehicle/{id}" }
    vehicles_create           = { method = "POST", path = "/api/Vehicle" }
    vehicles_update           = { method = "PUT", path = "/api/Vehicle/{id}" }
    vehicles_logical_deletion = { method = "PUT", path = "/api/Vehicle/{id}/LogicalDeletion" }
    vehicles_delete           = { method = "DELETE", path = "/api/Vehicle/{id}" }
  }
}

resource "aws_apigatewayv2_integration" "app" {
  for_each = local.app_routes

  api_id                 = aws_apigatewayv2_api.main.id
  integration_type       = "HTTP_PROXY"
  integration_method     = each.value.method
  integration_uri        = "${var.app_base_url}${each.value.path}"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_route" "app" {
  for_each = local.app_routes

  api_id    = aws_apigatewayv2_api.main.id
  route_key = "${each.value.method} ${each.value.path}"
  target    = "integrations/${aws_apigatewayv2_integration.app[each.key].id}"
}

# HTTP_PROXY sem VPC Link (VPC Link tem custo por hora e foge do free tier) chama o
# destino pela internet publica, sem IP de origem fixo — por isso a liberacao precisa
# ser para 0.0.0.0/0, no mesmo padrao das demais regras desse security group.
resource "aws_vpc_security_group_ingress_rule" "app_http_from_internet" {
  security_group_id = aws_security_group.app_server_sg.id
  description       = "HTTP da aplicacao principal, usado pelas integracoes HTTP_PROXY do API Gateway"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}
