# ============================================
# VARIÁVEIS PRINCIPAIS (RAIZ)
# ============================================
variable "aws_region" {
  description = "Região AWS onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Nome do bucket S3 para o estado remoto (deve ser único globalmente)"
  type        = string
  default     = "danilo-terraform-backend-2026"   # NOME ÚNICO
}

variable "instance_type" {
  description = "Tipo da instância EC2 – será sobrescrito pelo locals no main.tf"
  type        = string
  default     = "t2.micro"   # valor temporário
}

variable "meu_ip_cidr" {
  description = "Seu IP público no formato CIDR (ex: 1.2.3.4/32). Descubra com: curl -s https://checkip.amazonaws.com"
  type        = string
  default     = "200.000.000.000/32"
}

variable "portas_adicionais_liberadas" {
  description = "Lista de portas TCP adicionais a liberar no Security Group (além de 22 e 80)"
  type        = list(string)
  default     = ["443"]
}

variable "tags_extras" {
  description = "Mapa de tags adicionais a aplicar nos recursos (além de Name, Curso, Ambiente)"
  type        = map(string)
  default = {
    Equipe = "DevOps"
  }
}

variable "senha_exemplo" {
  description = "Valor sensível de exemplo (apenas demonstração)"
  type        = string
  default     = "senha-demo-nao-use-em-producao"
  sensitive   = true
}
