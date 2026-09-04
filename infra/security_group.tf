resource "aws_security_group" "app_server_sg" {
  name        = "tech-challenge-fase2-sg"
  description = "SG para a instancia do Tech Challenge Fase 2"
  vpc_id      = data.aws_subnet.app_server.vpc_id

  tags = {
    Name = "tech-challenge-fase2-sg"
  }

  lifecycle {
    ignore_changes = [ingress, egress]
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.app_server_sg.id
  description       = "SSH"
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "k8s_api" {
  security_group_id = aws_security_group.app_server_sg.id
  description       = "Kubernetes API (kube-apiserver)"
  ip_protocol       = "tcp"
  from_port         = 6443
  to_port           = 6443
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "nodeport" {
  security_group_id = aws_security_group.app_server_sg.id
  description       = "NodePort range (K8s services)"
  ip_protocol       = "tcp"
  from_port         = 30000
  to_port           = 32767
  cidr_ipv4         = "0.0.0.0/0"
}