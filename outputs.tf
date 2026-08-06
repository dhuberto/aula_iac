# ============================================
# OUTPUTS (RAIZ)
# ============================================
output "ip_publico_instancia" {
  description = "IP público da instância EC2"
  value       = module.webserver.public_ip
}

output "dns_publico_instancia" {
  description = "DNS público da instância"
  value       = module.webserver.public_dns
}

output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.webserver.vpc_id
}

output "subnet_id" {
  description = "ID da subnet pública"
  value       = module.webserver.subnet_id
}

output "security_group_id" {
  description = "ID do security group"
  value       = module.webserver.security_group_id
}

output "descricao_portas_adicionais" {
  description = "Descrição computada via locals"
  value       = local.descricao_portas_adicionais
}

output "tags_aplicadas" {
  description = "Tags aplicadas a todos os recursos"
  value       = local.tags_comuns
}

output "senha_exemplo_sensivel" {
  description = "Demonstração de output sensitive"
  value       = var.senha_exemplo
  sensitive   = true
}

output "workspace_atual" {
  description = "Workspace Terraform atual"
  value       = terraform.workspace
}
