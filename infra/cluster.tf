# Provisiona o cluster Kubernetes local (k3s). Reaproveita infra/scripts/install_k3s.sh
# (dentro deste proprio modulo, nao no repo_root da aplicacao), que instala o k3s se
# necessario e ajusta a permissao do kubeconfig. So roda de novo quando o conteudo do
# script muda (nao mais a cada apply) - reinstalar/reiniciar o k3s sem necessidade e
# em todo apply e caro num node de recursos limitados e ja causou instabilidade real.
resource "null_resource" "ensure_k3s_running" {
  triggers = {
    script_hash = filesha256("${path.module}/scripts/install_k3s.sh")
  }

  provisioner "local-exec" {
    # Invocado via "bash" (em vez de exec direto) para nao depender do bit de
    # execucao do arquivo sobreviver a um `git clone` novo.
    command = "sudo bash ${path.module}/scripts/install_k3s.sh"
  }
}
