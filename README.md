# Infraestrutura-Kubernetes-Terraform

Provisiona o cluster Kubernetes local (k3s) na instância EC2 do Tech Challenge e expõe o
PostgreSQL do `docker-compose` dentro do cluster (`infra/cluster.tf`, `infra/database.tf`).

## API Gateway + Lambda de autenticação

`infra/gateway.tf` publica um API Gateway HTTP (`POST /authenticate`) na frente da função
Lambda provisionada em [`Lambda-Function-Serverless`](https://github.com/jaimorais2007/Lambda-Function-Serverless).
A integração é feita via `terraform_remote_state`, lendo o state daquele repositório no
mesmo bucket S3 (`meu-bucket-terraform-state`, chave `auth-service/terraform.tfstate`).

Pré-requisitos para aplicar:

1. A Lambda em `Lambda-Function-Serverless` já ter sido aplicada (`terraform apply`), pois
   seu state é lido aqui como dependência.
2. Credenciais AWS com permissão para `apigateway:*` e `lambda:AddPermission` configuradas
   (mesmo perfil usado no restante do projeto, ver `infra/guia.md`).

```bash
cd infra
terraform init
terraform apply
```

Ao final, o output `auth_api_invoke_url` traz a URL completa para chamar
`POST /authenticate` com `{ "cpf": "..." }` no corpo.

Veja `infra/guia.md` para o passo a passo de acesso à instância EC2 via Terraform.

## ⚠️ Permissões AWS necessárias

O usuário IAM do projeto (`dev-techchallenge`) hoje só tem permissão de leitura em EC2 e
de gerenciar Security Groups (ver `infra/guia.md`). Testado na conta real (168126498555):
`apigateway:GET` retorna `AccessDenied`. Para aplicar `infra/gateway.tf` é preciso liberar
`apigateway:*` (ou as ações `POST/GET/PUT/DELETE` do `apigatewayv2`) e
`lambda:AddPermission`/`lambda:RemovePermission` na função de autenticação, além de
`s3:GetObject` no bucket `meu-bucket-terraform-state` para ler o state da Lambda.
