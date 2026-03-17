# infra/main.tf
# Este archivo define QUÉ infraestructura existe en AWS.
# Terraform lee esto y lo compara contra la realidad —
# si algo falta, lo crea. Si algo sobra, lo destruye.

# ── 1. PROVIDER ───────────────────────────────────────────────────
# Le dice a Terraform con qué nube hablar.
# Terraform soporta AWS, GCP, Azure, y más — el provider
# es el plugin que sabe cómo hablar con cada API.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # Las credenciales NO van aquí — Terraform las lee
  # automáticamente desde ~/.aws/credentials que configuraste
  # con "aws configure". Nunca hardcodees credenciales.
}

# ── 2. DATA SOURCE ────────────────────────────────────────────────
# Busca la AMI (imagen de servidor) más reciente de Amazon Linux.
# En lugar de hardcodear un ID que cambia por región,
# dejamos que Terraform lo encuentre dinámicamente.

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# ── 3. SECURITY GROUP ─────────────────────────────────────────────
# Define las reglas de firewall para nuestra instancia.
# Sin esto, ningún tráfico puede entrar ni salir.

resource "aws_security_group" "salary_predictor_sg" {
  name        = "salary-predictor-sg"
  description = "Allow HTTP and SSH access"

  # Permite tráfico entrante en puerto 8000 (nuestra API)
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite SSH para conectarnos al servidor si necesitamos
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permite todo el tráfico saliente
  # (necesario para que Docker pueda descargar la imagen)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ── 4. EC2 INSTANCE ───────────────────────────────────────────────
# El servidor donde va a correr tu container.
# t2.micro = la instancia más pequeña, entra en Free Tier.

resource "aws_instance" "salary_predictor" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.salary_predictor_sg.id]

  # user_data = script que corre automáticamente cuando
  # el servidor arranca por primera vez.
  # Aquí instalamos Docker y corremos tu container.
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    docker run -d -p 8000:8000 michaelynoa/salary-predictor:latest
  EOF

  tags = {
    Name        = "salary-predictor"
    Environment = "dev"
    Project     = "mlops-portfolio"
  }
}