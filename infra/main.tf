terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "techchallenge"
}

resource "aws_instance" "app_server" {
  ami           = local.ami
  instance_type = "t3.small"
  subnet_id     = local.subnet_id

  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  user_data                   = file("${path.module}/scripts/install_k3s.sh")

  tags = {
    Name = "tech-challenge-fase2"
  }

  lifecycle {
    prevent_destroy = true
  }
}

data "aws_subnet" "app_server" {
  id = local.subnet_id
}