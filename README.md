# Atividade 1 – Terraform

Provisionamento de infraestrutura web na AWS com Terraform, utilizando módulo próprio, state remoto S3 com DynamoDB para lock, e workspaces (dev/prod).

---

# Requisitos atendidos

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

# Pré-requisitos

- Terraform >= 1.0 instalado
- AWS CLI configurada com credenciais (ou variáveis de ambiente)
- Bucket S3 (será criado automaticamente pelo backend-setup.tf)

---
## Estrutura do projeto

```
~/aula_iac/
├── main.tf                     # Provider e chamada do módulo
├── variables.tf                # Variáveis
├── outputs.tf                  # Outputs
├── backend.tf                  # Backend S3 (com valores fixos)
├── backend-setup.tf            # Criação do bucket e tabela (executado uma vez)
├── backend-setup.tf.bak        # Backup após primeira execução
├── terraform.tfvars.example    # Exemplo de variáveis
├── .gitignore
├── README.md
└── modules/
    └── webserver/
        ├── main.tf             # Recursos: VPC, subnet, IGW, SG, EC2
        ├── variables.tf
        └── outputs.tf
```
---

# Preparação do Ambiente

# Linux (Debian/Ubuntu)

```bash 
sudo apt update
```

```bash 
sudo apt install -y git
```

# Instalação do Terraform

```bash 
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```

```bash 
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```

```bash 
sudo apt update
```

```bash 
sudo apt install -y terraform
```

# Crie conta AWS em aws.amazon.com e Instale do AWS CLI v2

```bash 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

```bash 
unzip awscliv2.zip
```

```bash 
sudo ./aws/install
```

# Execute o aws configure para colocar as credenciais:

```bash 
aws configure
```
```bash 
O comando vai pedir quatro informações, uma por vez:

# AWS Access Key ID [None]: <SUA_ACCESS_KEY_ID>
# AWS Secret Access Key [None]: <SUA_SECRET_ACCESS_KEY>
# Default region name [None]: us-east-1
# Default output format [None]: json
```

# Checklist final de verificação

```bash 
git --version
```
```bash
terraform -version
```
```bash
aws --version
```
```bash
aws sts get-caller-identity
```

O último comando confirma que suas credenciais IAM estão configuradas corretamente e mostra qual
usuário está autenticado. Saída esperada:
```bash
{
"UserId": "AIDAEXAMPLE123456789",
"Account": "123456789012",
"Arn": "arn:aws:iam::123456789012:user/devops-iac-curso"
}
```


# Configuração inicial

### 1. Clone o repositório

```bash
git clone https://github.com/dhuberto/aula_iac.git
```

```bash
cd ~/aula_iac
```

## Execute o comando abaixo para gerar o o novo terraform.tfvars terraform.tfvars (com seu IP real)
```bash
cp terraform.tfvars.example terraform.tfvars && sed -i "s/meu_ip_cidr = .*/meu_ip_cidr = \"$(curl -s https://checkip.amazonaws.com)\/32\"/" terraform.tfvars
```
## Crie o bucket S3 e a tabela DynamoDB (primeira execução) 
```bash
terraform init -reconfigure
```
```bash
terraform apply -auto-approve -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_locks
```

## Após a criação, renomeie o arquivo backend-setup.tf para evitar recriação acidental:
```bash
mv backend-setup.tf backend-setup.tf.bak
```
## Ative o backend remoto S3
```bash
mv backend.tf.disabled backend.tf
```

## Migrar o estado para o S3
```bash
terraform init -migrate-state
```

# Continuar com a criação default para criar ambientes separados:
```bash
terraform plan
```
```bash
terraform apply
```
# responda yes


## Crie os workspaces dos ambientes separados e aplique:
```bash
terraform workspace new dev && terraform workspace select dev && terraform apply -auto-approve
```
```bash
terraform workspace new prod && terraform workspace select prod && terraform apply -auto-approve
```

## O Resultado são os Output com os endereços de acesso de cada ambiente

## Validações e formatação
```bash
terraform fmt -check
```
```bash
terraform validate
```

# Caso queira Destruir (apagar tudo)
```bash
cd ~/aula_iac
```

```bash
terraform workspace select dev && terraform destroy -auto-approve
```
```bash
terraform workspace select prod && terraform destroy -auto-approve
```
```bash
aws s3 rb s3://danilo-terraform-backend-2026 --force
```
```bash
aws dynamodb delete-table --table-name terraform-locks
```

Ou 

```bash
terraform destroy
```
<small>Responda: <span style="color: red;">yes</span></small>


