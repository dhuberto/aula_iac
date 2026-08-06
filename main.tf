# ============================================
# MAIN.TF – CHAMADA DO MÓDULO WEBSERVER
# ============================================
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  ambiente = terraform.workspace

  # Cálculo do tipo de instância baseado no workspace
  instance_type = terraform.workspace == "prod" ? "t3.micro" : "t2.micro"

  tags_comuns = merge(
    {
      Name     = "instancia-curso-variaveis-outputs"
      Curso    = "pos-devops-iac"
      Ambiente = local.ambiente
    },
    var.tags_extras
  )

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y httpd
    systemctl enable httpd
    systemctl start httpd
    cat <<HTML > /var/www/html/index.html
    <html>
    <body>
    <h1>Atividade 1 - Terraform</h1>
    <p>Data: 2026-08-06</p>
    <p>Aluno: Danilo Huberto</p>
    <p>Turma: 2025.2</p>
    <p>Ambiente: ${local.ambiente}</p>
    </body>
    </html>
    HTML
  EOF

  descricao_portas_adicionais = "Portas adicionais liberadas: ${join(", ", var.portas_adicionais_liberadas)}"
}

module "webserver" {
  source = "./modules/webserver"

  aws_region       = var.aws_region
  instance_type    = local.instance_type   # agora usa o valor calculado
  meu_ip_cidr      = var.meu_ip_cidr
  portas_adicionais = var.portas_adicionais_liberadas
  tags_comuns      = local.tags_comuns
  user_data        = local.user_data
}
