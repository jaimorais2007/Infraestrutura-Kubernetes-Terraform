terraform {
  required_version = ">= 1.5.0"

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
