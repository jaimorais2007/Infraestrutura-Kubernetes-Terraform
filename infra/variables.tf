variable "kubeconfig_path" {
  description = "Caminho do kubeconfig do k3s local"
  type        = string
  default     = "/etc/rancher/k3s/k3s.yaml"
}

variable "k8s_namespace" {
  description = "Namespace onde a aplicacao e o Service do banco sao criados"
  type        = string
  default     = "default"
}

variable "repo_root" {
  description = "Caminho da raiz do repositorio (para rodar docker compose e o script do k3s)"
  type        = string
  default     = ".."
}

variable "db_port" {
  description = "Porta do PostgreSQL publicada pelo docker-compose no host"
  type        = number
  default     = 5432
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
