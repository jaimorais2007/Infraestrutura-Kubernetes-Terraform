terraform {
  required_version = ">= 1.5.0"

  # State remoto: a instancia EC2 e o security group reais (importados) precisam do
  # mesmo state em qualquer lugar que este repo for aplicado (ex.: de dentro da propria
  # EC2 via SSH) - com backend local, um clone novo comecaria com state vazio e tentaria
  # criar uma instancia/SG duplicados.
  backend "s3" {
    bucket = "techchallenge-terraform-state-s3"
    key    = "gateway/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.3"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Usado apenas pelos recursos de API Gateway (infra/gateway.tf), que expõem a
# Lambda de autenticação provisionada no repositório Lambda-Function-Serverless.
provider "aws" {
  region = var.aws_region
}
