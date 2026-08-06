# ============================================
# VARIÁVEIS DO MÓDULO WEBSERVER
# ============================================
variable "aws_region" {
  description = "Região AWS (usada para data sources)"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
}

variable "meu_ip_cidr" {
  description = "Seu IP público no formato CIDR (ex: 1.2.3.4/32)"
  type        = string
}

variable "portas_adicionais" {
  description = "Lista de portas TCP adicionais a liberar (além de 22 e 80)"
  type        = list(string)
  default     = []
}

variable "tags_comuns" {
  description = "Tags comuns aplicadas a todos os recursos"
  type        = map(string)
  default     = {}
}

variable "user_data" {
  description = "Script de inicialização da instância (user_data)"
  type        = string
  default     = null
}
