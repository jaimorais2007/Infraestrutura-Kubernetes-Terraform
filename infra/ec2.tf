# Instância EC2 já existente do Tech Challenge (importada via `terraform import
# aws_instance.app_server i-0d529510ddbb7e458`, ver infra/guia.md). Os valores abaixo
# foram conferidos contra a instância real (aws ec2 describe-instances) para que o plano
# fique "0 to destroy, 0 to change" — nenhum atributo aqui deve ser alterado sem antes
# comparar com a instância real, pois varios deles (ami, user_data) forcam recriacao.
locals {
  subnet_id = "subnet-00c1dffa4498744cf"
  ami       = "ami-0ec10929233384c7f"
}

data "aws_subnet" "app_server" {
  id = local.subnet_id
}

resource "aws_instance" "app_server" {
  ami           = local.ami
  instance_type = "t3.large"
  subnet_id     = local.subnet_id
  key_name      = "key_ssh_aws"

  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  # A instancia real nao tem user_data configurado (k3s foi instalado via SSH) -
  # nao declarar aqui, senao o provider AWS forca a recriacao da instancia.

  tags = {
    Name = "tech-challenge-fase2"
  }

  lifecycle {
    prevent_destroy = true
    # O state local tem um hash de user_data que nao bate com a instancia real
    # (confirmado via `aws ec2 describe-instance-attribute --attribute userData`,
    # que retorna vazio). Ignorar para nunca tentar alterar isso numa instancia em uso.
    ignore_changes = [user_data]
  }
}
