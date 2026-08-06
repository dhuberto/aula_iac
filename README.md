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
