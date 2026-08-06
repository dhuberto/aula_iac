# ============================================
# OUTPUTS DO MÓDULO WEBSERVER
# ============================================
output "public_ip" {
  description = "IP público da instância"
  value       = aws_instance.server.public_ip
}

output "public_dns" {
  description = "DNS público da instância"
  value       = aws_instance.server.public_dns
}

output "vpc_id" {
  description = "ID da VPC criada"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "ID da subnet pública"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID do security group"
  value       = aws_security_group.web.id
}
