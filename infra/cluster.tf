# Provisiona o cluster Kubernetes local (k3s). Reaproveita infra/scripts/install_k3s.sh
# (dentro deste proprio modulo, nao no repo_root da aplicacao), que instala o k3s se
# necessario e ajusta a permissao do kubeconfig. Roda a cada apply para garantir que o
# cluster esteja de pe (idempotente).
resource "null_resource" "ensure_k3s_running" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = "sudo ${path.module}/scripts/install_k3s.sh"
  }
}
