# Guia de Acesso à Instância EC2 via Terraform
### Tech Challenge - Fase 2 (POS TECH)

---

## Informações do Ambiente

| Item | Valor |
|---|---|
| Instance ID (EC2) | `i-0d529510ddbb7e458` |
| Região AWS | `us-east-1` (N. Virginia) |
| Usuário IAM | `dev-techchallenge` |
| Account ID | `168126498555` |
| Perfil local (profile) | `techchallenge` |
| Backend do state | Local (arquivo `terraform.tfstate` na própria pasta) |
| Acesso SSH necessário? | Não — apenas via API da AWS (Terraform) |

---

## Pré-requisitos

- Acesso via terminal (Linux/Ubuntu)
- Credenciais AWS já geradas para o usuário `dev-techchallenge` (Access Key ID + Secret Access Key)

---

## Passo 1 — Instalar a AWS CLI

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install -y unzip
unzip awscliv2.zip
sudo ./aws/install
```

Verificar instalação:
```bash
aws --version
```

---

## Passo 2 — Instalar o Terraform

```bash
sudo apt update
sudo apt install -y gnupg software-properties-common curl
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt install -y terraform
```

Verificar instalação:
```bash
terraform -version
```

---

## Passo 3 — Configurar as credenciais AWS

```bash
aws configure --profile techchallenge
```

Preencher com os dados recebidos:
```
AWS Access Key ID: <recebido por canal seguro>
AWS Secret Access Key: <recebido por canal seguro>
Default region name: us-east-1
Default output format: json
```

> ⚠️ Copie e cole direto da origem das credenciais (não digite manualmente) para evitar erros de caracteres.

---

## Passo 4 — Testar se o acesso está funcionando

```bash
AWS_PROFILE=techchallenge aws sts get-caller-identity
```

**Resultado esperado:**
```json
{
    "UserId": "AIDASOJI6Y35WWOZG6R7O",
    "Account": "168126498555",
    "Arn": "arn:aws:iam::168126498555:user/dev-techchallenge"
}
```

Se aparecer erro `InvalidClientTokenId`, revise o Passo 3 — geralmente é Access Key ou Secret colados incorretamente.

---

## Passo 5 — Criar a estrutura do projeto Terraform

```bash
mkdir -p ~/tech-challenge/infra
cd ~/tech-challenge/infra
```

---

## Passo 6 — Criar o arquivo `main.tf`

```bash
nano main.tf
```

Cole o conteúdo abaixo:

```hcl
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
  lifecycle {
    prevent_destroy = true
  }
}
```

Salvar: `Ctrl+O`, `Enter`, `Ctrl+X`

---

## Passo 7 — Criar o `.gitignore` (proteger o state local)

```bash
nano .gitignore
```

Cole:
```
*.tfstate
*.tfstate.backup
.terraform/
.terraform.lock.hcl
```

---

## Passo 8 — Inicializar o Terraform

```bash
terraform init
```

**Resultado esperado:** `Terraform has been successfully initialized!`

---

## Passo 9 — Importar a instância EC2 existente

```bash
terraform import aws_instance.app_server i-0d529510ddbb7e458
```

**Resultado esperado:** `Import successful!`

---

## Passo 10 — Visualizar os atributos reais da instância

```bash
terraform show
```

Copie os campos principais (`ami`, `instance_type`, `subnet_id`) e atualize o `main.tf`:

```hcl
resource "aws_instance" "app_server" {
  ami           = "ami-xxxxxxxxxxxxxxxxx"   # copiar do terraform show
  instance_type = "t2.micro"                 # copiar do terraform show
  subnet_id     = "subnet-xxxxxxxx"           # copiar do terraform show

  tags = {
    Name = "tech-challenge-fase2"
  }

  lifecycle {
    prevent_destroy = true
  }
}
```

---

## Passo 11 — Validar que o import ficou correto

```bash
terraform plan
```

**Resultado esperado:** `No changes. Your infrastructure matches the configuration.`

Se aparecer alguma alteração destrutiva ("will be replaced" ou "will be destroyed"), **não aplique** — ajuste o `.tf` até bater exatamente com o que já existe.

---

## Passo 12 — Validar a sintaxe do projeto

```bash
terraform validate
```

**Resultado esperado:** `Success! The configuration is valid.`

---

## Checklist resumido de comandos (nesta ordem)

```bash
aws configure --profile techchallenge
AWS_PROFILE=techchallenge aws sts get-caller-identity
mkdir -p ~/tech-challenge/infra && cd ~/tech-challenge/infra
terraform init
terraform import aws_instance.app_server i-0d529510ddbb7e458
terraform show
terraform plan
terraform validate
```

---

## Próximos passos (após o acesso confirmado)

- Criar o `aws_security_group` liberando as portas necessárias (22, 6443, 30000-32767)
- Associar o Security Group à instância importada
- Rodar `terraform apply` para efetivar as mudanças de infraestrutura
- Documentar os recursos criados no `README.md` do repositório (exigido no Tech Challenge)

---

## Observações de segurança

- O usuário `dev-techchallenge` tem permissões restritas apenas a: leitura de recursos EC2 e gerenciamento de Security Groups.
- O state do Terraform está sendo mantido **localmente** (não há backend remoto configurado) — por isso é fundamental não excluir o arquivo `terraform.tfstate` sem backup, e mantê-lo fora do controle de versão (Git).
- Não compartilhar Access Key / Secret Access Key por canais públicos ou não criptografados.
