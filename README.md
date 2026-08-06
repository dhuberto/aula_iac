# Atividade 1 – Terraform

Provisionamento de infraestrutura web na AWS com Terraform, utilizando módulo próprio, state remoto S3 com DynamoDB para lock, e workspaces (dev/prod).

---

## Requisitos atendidos

- VPC com subnet pública, Internet Gateway e route table
- Security Group com SSH restrito ao IP do aluno e HTTP aberto
- Instância EC2 com Amazon Linux 2023 (AMI dinâmica)
- User_data que instala httpd e exibe nome, turma e ambiente
- Módulo próprio em modules/webserver
- State remoto com backend S3 (bucket versionado) e DynamoDB para lock
- Workspaces dev e prod com instance_type variável (t2.micro em dev, t3.micro em prod)
- Tags consistentes: Name, Curso, Ambiente
- Código formatado e validado (terraform fmt -check, terraform validate)
- Nenhuma credencial commitada

---

## Pré-requisitos

- Terraform >= 1.0 instalado
- AWS CLI configurada com credenciais (ou variáveis de ambiente)
- Bucket S3 (será criado automaticamente pelo backend-setup.tf)

---

## Configuração inicial

### 1. Clone o repositório

```bash
git clone https://github.com/dhuberto/aula_iac.git
cd ~/aula_iac
```

```bash
git clone https://github.com/dhuberto/aula_iac.git
```
```bash
cd ~/aula_iac/
cp terraform.tfvars.example terraform.tfvars
```

##Execute o comando abaixo para gerar o o novo terraform.tfvars terraform.tfvars (com seu IP real)

cp terraform.tfvars.example terraform.tfvars && sed -i "s/meu_ip_cidr = .*/meu_ip_cidr = \"$(curl -s https://checkip.amazonaws.com)\/32\"/" terraform.tfvars

##Crie o bucket S3 e a tabela DynamoDB (primeira execução) 
```bash
terraform init -reconfigure
terraform apply -auto-approve -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_locks
```

##Após a criação, renomeie o arquivo backend-setup.tf para evitar recriação acidental:
```bash
mv backend-setup.tf backend-setup.tf.bak
```


##Migrar o estado para o S3
```bash
terraform init -migrate-state
```

#Continuar com a criação default para criar ambientes separados:
```bash
terraform plan
terraform apply
#responta yes
```

##Crie os workspaces dos ambientes separados e aplique:
```bash
terraform workspace new dev && terraform workspace select dev && terraform apply -auto-approve
terraform workspace new prod && terraform workspace select prod && terraform apply -auto-approve
```

## O Resultado são os Output com os endereços de acesso de cada ambiente


#Caso queira Destruir (apagar tudo)
```bash
terraform workspace select dev && terraform destroy -auto-approve
terraform workspace select prod && terraform destroy -auto-approve
aws s3 rb s3://danilo-terraform-backend-2026 --force
aws dynamodb delete-table --table-name terraform-locks
```

