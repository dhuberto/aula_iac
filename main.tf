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
  ambiente      = terraform.workspace
  instance_type = terraform.workspace == "prod" ? "t3.micro" : "t2.micro"

  tags_comuns = merge(
    {
      Name     = "instancia-curso-variaveis-outputs"
      Curso    = "pos-devops-iac"
      Ambiente = local.ambiente
    },
    var.tags_extras
  )

  # ==========user_data via templatefile === infomações apresentada a pagina web=======
  user_data = templatefile("${path.module}/templates/user_data.sh.tpl", {
    data     = "06/07/2026"
    aluno    = "Danilo Huberto"
    turma    = "2025.2"
    ambiente = local.ambiente
  })
  # =====================================================

  descricao_portas_adicionais = "Portas adicionais liberadas: ${join(", ", var.portas_adicionais_liberadas)}"
}

module "webserver" {
  source = "./modules/webserver"

  aws_region        = var.aws_region
  instance_type     = local.instance_type
  meu_ip_cidr       = var.meu_ip_cidr
  portas_adicionais = var.portas_adicionais_liberadas
  tags_comuns       = local.tags_comuns
  user_data         = local.user_data

}
