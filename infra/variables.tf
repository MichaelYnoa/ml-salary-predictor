# infra/variables.tf
# Centraliza todos los valores configurables.
# En lugar de hardcodear "us-east-1" en 10 lugares,
# lo defines una vez aquí y lo referencias con var.nombre.

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type — t3.micro is Free Tier eligible"
  type        = string
  default     = "t3.micro"
}