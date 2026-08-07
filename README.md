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
├── Output.tf                   # Output
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
Comando: 
```bash 
sudo apt update
```
Comando: 
```bash 
sudo apt install -y git
```

## Instalação do Terraform
Comando: 
```bash 
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```
Comando: 
```bash 
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```
Comando: 
```bash 
sudo apt update
```
Comando: 
```bash 
sudo apt install -y terraform
```

## Crie conta AWS em aws.amazon.com e Instale do AWS CLI v2
Comando: 
```bash 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
```
Comando: 
```bash 
unzip awscliv2.zip
```
Comando: 
```bash 
sudo ./aws/install
```

## Execute o aws configure para colocar as credenciais:
Comando: 
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
Comandos: 
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

### Clone o repositório
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

### Executando o terraform plan para identificar se o terraform consegue acessar o estado remoto 

Comando:
```bash
terraform plan
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
terraform workspace new dev || terraform workspace select dev && terraform apply -auto-approve
```
<small>

<img width="855" height="384" alt="{A0F134D8-A43D-4FB9-9A0F-8207327C0C43}" src="https://github.com/user-attachments/assets/866894c6-7bfd-4b11-892a-645401c86f12" />
    
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
terraform workspace new prod || terraform workspace select prod && terraform apply -auto-approve
```
<small>

<img width="856" height="328" alt="{1BF22815-CB7A-45E1-A249-2A4D9CFDCDE0}" src="https://github.com/user-attachments/assets/58de442c-09e1-4026-874f-b23a68f54ae8" />

    
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
Output:
```bash
Success! The configuration is valid.
```

## Caso queira Destruir (apagar tudo)
Comando: 
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
module.webserver.aws_route_table_association.public: Destroying... [id=rtbassoc-086c865cd4b81da98]
module.webserver.aws_instance.server: Destroying... [id=i-045677b2699cd5d15]
module.webserver.aws_route_table_association.public: Destruction complete after 1s
module.webserver.aws_route_table.public: Destroying... [id=rtb-0815bb4c1141245fc]
module.webserver.aws_route_table.public: Destruction complete after 1s
module.webserver.aws_internet_gateway.main: Destroying... [id=igw-03fd01332530507bc]
module.webserver.aws_instance.server: Still destroying... [id=i-045677b2699cd5d15, 00m52s elapsed]
module.webserver.aws_internet_gateway.main: Still destroying... [id=igw-03fd01332530507bc, 00m50s elapsed]
module.webserver.aws_instance.server: Destruction complete after 53s
module.webserver.aws_subnet.public: Destroying... [id=subnet-0955454dd42a61e07]
module.webserver.aws_security_group.web: Destroying... [id=sg-09362f9348efa5734]
module.webserver.aws_internet_gateway.main: Destruction complete after 51s
module.webserver.aws_subnet.public: Destruction complete after 1s
module.webserver.aws_security_group.web: Destruction complete after 1s
module.webserver.aws_vpc.main: Destroying... [id=vpc-036941e8faebe8e8c]
module.webserver.aws_vpc.main: Destruction complete after 1s

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
module.webserver.aws_route_table_association.public: Destroying... [id=rtbassoc-0a65b0b4d4d9b7311]
module.webserver.aws_instance.server: Destroying... [id=i-02ac340ba2d7a80c3]
module.webserver.aws_route_table_association.public: Destruction complete after 1s
module.webserver.aws_route_table.public: Destroying... [id=rtb-098662824c2d67f35]
module.webserver.aws_route_table.public: Destruction complete after 1s
module.webserver.aws_internet_gateway.main: Destroying... [id=igw-0cb28c35a9a7955bf]
module.webserver.aws_instance.server: Still destroying... [id=i-02ac340ba2d7a80c3, 00m10s elapsed]
module.webserver.aws_internet_gateway.main: Still destroying... [id=igw-0cb28c35a9a7955bf, 00m10s elapsed]
module.webserver.aws_instance.server: Still destroying... [id=i-02ac340ba2d7a80c3, 00m20s elapsed]
module.webserver.aws_internet_gateway.main: Still destroying... [id=igw-0cb28c35a9a7955bf, 00m28s elapsed]
module.webserver.aws_instance.server: Still destroying... [id=i-02ac340ba2d7a80c3, 00m30s elapsed]
module.webserver.aws_internet_gateway.main: Still destroying... [id=igw-0cb28c35a9a7955bf, 00m38s elapsed]
module.webserver.aws_instance.server: Still destroying... [id=i-02ac340ba2d7a80c3, 00m40s elapsed]
module.webserver.aws_internet_gateway.main: Still destroying... [id=igw-0cb28c35a9a7955bf, 00m48s elapsed]
module.webserver.aws_instance.server: Still destroying... [id=i-02ac340ba2d7a80c3, 00m50s elapsed]
module.webserver.aws_instance.server: Destruction complete after 51s
module.webserver.aws_security_group.web: Destroying... [id=sg-089d42feac6d09544]
module.webserver.aws_subnet.public: Destroying... [id=subnet-0805c867ef357b49b]
module.webserver.aws_internet_gateway.main: Destruction complete after 50s
module.webserver.aws_subnet.public: Destruction complete after 1s
module.webserver.aws_security_group.web: Destruction complete after 1s
module.webserver.aws_vpc.main: Destroying... [id=vpc-0d5a351a0fba8e29b]
module.webserver.aws_vpc.main: Destruction complete after 0s

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

### Apagar o Diretório do Projeto na maquina Local

Comando:
```bash
cd ..
```
Comando:
```bash
rm -rf aula_iac
```
Tudo Limpo!

[![Download ZIP](https://img.shields.io/badge/Download-ZIP-blue?style=for-the-badge&logo=github)](https://github.com/dhuberto/aula_iac/archive/main.zip)
