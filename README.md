# Infraestrutura-Kubernetes-Terraform

Gerencia a instância EC2 do Tech Challenge (`infra/ec2.tf`, `infra/security_group.tf`,
importados de `i-0d529510ddbb7e458`), provisiona o cluster Kubernetes local (k3s) nela
e expõe o PostgreSQL do `docker-compose` dentro do cluster (`infra/cluster.tf`,
`infra/database.tf`).

> `infra/ec2.tf` e `infra/security_group.tf` foram reconstruídos a partir dos atributos
> reais da instância (`aws ec2 describe-instances`) para que `terraform plan` fique
> `0 to destroy` — não remova esses recursos do `.tf` sem antes rodar `terraform state rm`,
> ou o Terraform vai tentar destruir a instância/security group reais.

## API Gateway

`infra/gateway.tf` publica um API Gateway HTTP com duas frentes:

- `POST /authenticate` → Lambda de autenticação por CPF, provisionada em
  [`Lambda-Function-Serverless`](https://github.com/jaimorais2007/Lambda-Function-Serverless)
  (integração `AWS_PROXY`, lida via `terraform_remote_state` no bucket S3
  `techchallenge-terraform-state-s3`, chave `auth-service/terraform.tfstate`).
- `infra/app_routes.tf` → todas as rotas da aplicação principal
  ([`Aplicacao-principal-executando-em-Kubernetes`](https://github.com/jaimorais2007/Aplicacao-principal-executando-em-Kubernetes),
  controllers em `src/OficinaApi.Presentation/Controllers`), via integração `HTTP_PROXY`
  apontando para o IP público do EC2 na porta 80 (`var.app_base_url`), onde o Service
  `type: LoadBalancer` do k3s (ServiceLB) expõe a API. Sem VPC Link (custo por hora, fora
  do free tier), então a porta 80 do security group é liberada para `0.0.0.0/0` — os
  endpoints seguem protegidos pelo JWT da própria aplicação (`[Authorize]`).

Pré-requisitos para aplicar:

1. A Lambda em `Lambda-Function-Serverless` já ter sido aplicada (`terraform apply`), pois
   seu state é lido aqui como dependência.
2. O cluster k3s e a aplicação principal já no ar (para as rotas em `app_routes.tf`
   responderem).

```bash
cd infra
terraform init
terraform apply
```

Ao final, o output `auth_api_invoke_url` traz a URL completa para chamar
`POST /authenticate` com `{ "cpf": "..." }` no corpo. As demais rotas ficam disponíveis
no mesmo `invoke_url` da API, ex.: `<invoke_url>/api/Vehicle`.

Veja `infra/guia.md` para o passo a passo de acesso à instância EC2 via Terraform.

## Custos / free tier

- Lambda, API Gateway (HTTP API) e S3 (apenas para o state) ficam dentro do free tier no
  uso esperado deste projeto — sem VPC Link, sem NAT Gateway, sem Load Balancer da AWS
  (o "LoadBalancer" do Service é o ServiceLB do próprio k3s, sem custo adicional).
- O único custo real e contínuo é a instância EC2 (`t3.medium`) em si, que já existia
  antes deste Terraform e não é criada por ele.
