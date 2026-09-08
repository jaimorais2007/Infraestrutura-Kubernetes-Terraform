variable "kubeconfig_path" {
  description = "Caminho do kubeconfig do k3s local (referencia informativa - o Service/Endpoints do Postgres em si é gerenciado pelo repositório Infra-Banco-de-Dados-Gerenciado-Terraform, não aqui)"
  type        = string
  default     = "/etc/rancher/k3s/k3s.yaml"
}

variable "aws_region" {
  description = "Região AWS onde o API Gateway e a Lambda de autenticação estão publicados"
  type        = string
  default     = "us-east-1"
}

variable "app_base_url" {
  description = "URL pública (IP do EC2) onde a aplicação principal (oficina-mecanica-api) está exposta via Service LoadBalancer do k3s na porta 80"
  type        = string
  default     = "http://52.204.203.192"
}
