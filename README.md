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
├── Output.tf                  # Output
├── backend.tf.disabled         # Desativado (renomear para .tf após criar o bucket)
├── backend-setup.tf            # Criação do bucket e tabela (executado uma vez, depois renomear .bak)
├── terraform.tfvars.example    # Exemplo de variáveis
├── .gitignore
├── README.md
└── modules/
    └── webserver/
        ├── main.tf             # Recursos: VPC, subnet, IGW, SG, EC2
        ├── variables.tf
        └── Output.tf
```
---

## Preparação do Ambiente

## Linux (Debian/Ubuntu)

```bash 
sudo apt update
```

```bash 
sudo apt install -y git
```

## Instalação do Terraform

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

## Crie conta AWS em aws.amazon.com e Instale do AWS CLI v2

```bash 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```

```bash 
unzip awscliv2.zip
```

```bash 
sudo ./aws/install
```

## Execute o aws configure para colocar as credenciais:

```bash 
aws configure
```

```bash

O comando vai pedir cinco informações, uma por vez:

# AWS Access Key ID [None]: <SUA_ACCESS_KEY_ID>
# AWS Secret Access Key [None]: <SUA_SECRET_ACCESS_KEY>
# AWS Session Token [None]: <SEU_SESSION_TOKEN>
# Default region name [None]: us-east-1
# Default output format [None]: json

Serão criados os arquivos:
~/.aws/credentials
~/.aws/config
# São os tokens de login e senha

```

## Checklist final de verificação

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


## Configuração inicial

### 1. Clone o repositório
Comando: 
```bash
git clone https://github.com/dhuberto/aula_iac.git
```
Comando: 
```bash
cd ~/aula_iac
```

### Execute o comando abaixo para gerar o o novo terraform.tfvars terraform.tfvars (com seu IP real)
Comando: 
```bash
cp terraform.tfvars.example terraform.tfvars && sed -i "s/meu_ip_cidr = .*/meu_ip_cidr = \"$(curl -s https://checkip.amazonaws.com)\/32\"/" terraform.tfvars
```
## Crie o bucket S3 e a tabela DynamoDB Cria (backend local) (primeira execução) 
Comando: 
```bash
terraform init -reconfigure
```
Comando: 
```bash
terraform apply -auto-approve -target=aws_s3_bucket.terraform_state -target=aws_dynamodb_table.terraform_locks
```

### Após a criação, renomeie o arquivo backend-setup.tf para evitar recriação acidental:
Comando: 
```bash
mv backend-setup.tf backend-setup.tf.bak
```

### Ative o backend remoto S3
Comando: 
```bash
mv backend.tf.disabled backend.tf
```

### Migrar o estado para o S3
Comando: 
```bash
terraform init -migrate-state
```
<small>Responda: <span style="color: red;">yes</span></small>

### Crie os workspaces dos ambientes separados e aplique:
Comando: 
```bash
terraform workspace new dev && terraform workspace select dev && terraform apply -auto-approve
```
<small>
    
Output:

```bash
descricao_portas_adicionais = "Portas adicionais liberadas: 22"
dns_publico_instancia = "ec2-54-242-xxx-xxx.compute-1.amazonaws.com"
ip_publico_instancia = "54.242.xxx.xxx"
security_group_id = "sg-039efaexxx"
senha_exemplo_sensivel = <sensitive>
subnet_id = "subnet-078e1191xxx"
tags_aplicadas = {
  "Ambiente" = "dev"
  "Curso" = "pos-devops-iac"
  "Equipe" = "DevOps"
  "Name" = "instancia-curso-variaveis-Output"
}
vpc_id = "vpc-xxx"
workspace_atual = "dev"
```
</small>

Comando:     
```bash
terraform workspace new prod && terraform workspace select prod && terraform apply -auto-approve
```
<small>
    
Output:

```bash
descricao_portas_adicionais = "Portas adicionais liberadas: 22"
dns_publico_instancia = "ec2-54-210-xxx-xxx.compute-1.amazonaws.com"
ip_publico_instancia = "54.210.xxx.xxx"
security_group_id = "sg-0192f93a3bcxxx"
senha_exemplo_sensivel = <sensitive>
subnet_id = "subnet-0e6d7062145xxx"
tags_aplicadas = {
  "Ambiente" = "prod"
  "Curso" = "pos-devops-iac"
  "Equipe" = "DevOps"
  "Name" = "instancia-curso-variaveis-Output"
}
vpc_id = "vpc-0382c834120xxx"
workspace_atual = "prod"
```
</small>

### O Resultado são os Output com os endereços de acesso de cada ambiente

### Validações e formatação
Comando: 
```bash
terraform fmt -check
```
Output:
```bash
backend.tf
main.tf
terraform.tfvars
variables.tf
```
Comando: 
```bash
terraform validate
```
```bash
Success! The configuration is valid.
```

## Caso queira Destruir (apagar tudo)

```bash
cd ~/aula_iac
```
Comando: 
```bash
terraform workspace select dev && terraform destroy -auto-approve
```
<small>
    
Output:

```bash
module.webserver.aws_route_table_association.public: Destroying... [id=rtbassoc-08d6e3e72fe176e97]
module.webserver.aws_instance.server: Destroying... [id=i-0ada4f3bdba3c35da]
module.webserver.aws_route_table_association.public: Destruction complete after 2s
module.webserver.aws_route_table.public: Destroying... [id=rtb-009389562204e529c]
module.webserver.aws_route_table.public: Destruction complete after 1s
module.webserver.aws_internet_gateway.main: Destroying... [id=igw-099d362b60d62ad9d]
module.webserver.aws_instance.server: Still destroying... [id=i-0ada4f3bdba3c35da, 00m10s elapsed]
module.webserver.aws_internet_gateway.main: Still destroying... [id=igw-099d362b60d62ad9d, 00m10s elapsed]
module.webserver.aws_instance.server: Still destroying... [id=i-0ada4f3bdba3c35da, 00m20s elapsed]
module.webserver.aws_internet_gateway.main: Still destroying... [id=igw-099d362b60d62ad9d, 00m20s elapsed]
module.webserver.aws_internet_gateway.main: Still destroying... [id=igw-099d362b60d62ad9d, 00m43s elapsed]
module.webserver.aws_instance.server: Still destroying... [id=i-0ada4f3bdba3c35da, 00m46s elapsed]
module.webserver.aws_instance.server: Destruction complete after 47s
module.webserver.aws_subnet.public: Destroying... [id=subnet-078e1191d54cc20d0]
module.webserver.aws_security_group.web: Destroying... [id=sg-039efae4c2d379540]
module.webserver.aws_internet_gateway.main: Destruction complete after 45s
module.webserver.aws_security_group.web: Destruction complete after 1s
module.webserver.aws_subnet.public: Destruction complete after 1s
module.webserver.aws_vpc.main: Destroying... [id=vpc-0f85088cf31f9df46]
module.webserver.aws_vpc.main: Destruction complete after 0s
Releasing state lock. This may take a few moments...

Destroy complete! Resources: 7 destroyed.
```
</small>

Comando: 
```bash
terraform workspace select prod && terraform destroy -auto-approve
```
<small>
    
Output:
```bash
module.webserver.aws_route_table_association.public: Destroying... [id=rtbassoc-0f1deb0cfec31c8aa]
module.webserver.aws_instance.server: Destroying... [id=i-04554525911f9a754]
module.webserver.aws_route_table_association.public: Destruction complete after 1s
module.webserver.aws_route_table.public: Destroying... [id=rtb-0e396842687ae1b83]
module.webserver.aws_route_table.public: Destruction complete after 1s
module.webserver.aws_internet_gateway.main: Destroying... [id=igw-070675fba1eec7251]
module.webserver.aws_instance.server: Still destroying... [id=i-04554525911f9a754, 00m42s elapsed]
module.webserver.aws_internet_gateway.main: Still destroying... [id=igw-070675fba1eec7251, 00m42s elapsed]
module.webserver.aws_instance.server: Destruction complete after 44s
module.webserver.aws_internet_gateway.main: Destruction complete after 43s
module.webserver.aws_security_group.web: Destroying... [id=sg-0192f93a3bc74c1b3]
module.webserver.aws_subnet.public: Destroying... [id=subnet-0e6d70621453ce7df]
module.webserver.aws_subnet.public: Destruction complete after 1s
module.webserver.aws_security_group.web: Destruction complete after 1s
module.webserver.aws_vpc.main: Destroying... [id=vpc-0382c834120639524]
module.webserver.aws_vpc.main: Destruction complete after 1s
Releasing state lock. This may take a few moments...

Destroy complete! Resources: 7 destroyed.
```
</small>

Comando: 

```bash
aws s3 rb s3://danilo-terraform-backend-2026 --force
```
<small>
    
Output:

```bash
delete: s3://danilo-terraform-backend-2026/terraform/atividade1/terraform.tfstate
delete: s3://danilo-terraform-backend-2026/env:/dev/terraform/atividade1/terraform.tfstate
delete: s3://danilo-terraform-backend-2026/env:/prod/terraform/atividade1/terraform.tfstate
remove_bucket: danilo-terraform-backend-2026
```
</small>
Comando:    
```bash
aws dynamodb delete-table --table-name terraform-locks
```
<small>
    
Output:

```bash
{
    "TableDescription": {
        "TableName": "terraform-locks",
        "TableStatus": "DELETING",
        "ProvisionedThroughput": {
            "NumberOfDecreasesToday": 0,
            "ReadCapacityUnits": 0,
            "WriteCapacityUnits": 0
        },
        "TableSizeBytes": 0,
        "ItemCount": 0,
        "TableArn": "arn:aws:dynamodb:us-east-1:713415863067:table/terraform-locks",
        "TableId": "3f07c598-66d7-4257-aa20-33ba503360ad",
        "BillingModeSummary": {
            "BillingMode": "PAY_PER_REQUEST",
            "LastUpdateToPayPerRequestDateTime": "2026-08-06T16:01:00.483000-03:00"
        },
        "DeletionProtectionEnabled": false
    }
}
```
</small>
