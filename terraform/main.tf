terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 1. Criação da VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "flash-sales-vpc"
  }
}

# 2. Criação de Subnets (O RDS exige pelo menos 2 subnets em zonas diferentes)
resource "aws_subnet" "subnet_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "flash-sales-subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "flash-sales-subnet-2"
  }
}

# 3. DB Subnet Group (Necessário para o RDS saber onde se alojar)
resource "aws_db_subnet_group" "main" {
  name       = "flash-sales-db-subnet-group"
  subnet_ids = [aws_subnet.subnet_1.id, aws_subnet.subnet_2.id]

  tags = {
    Name = "Flash Sales DB Subnet Group"
  }
}

# 4. Banco de Dados Principal (Master)
resource "aws_db_instance" "master" {
  identifier             = "flash-sales-db-master"
  engine                 = "postgres"
  engine_version         = "15.4" # Versão do PostgreSQL
  instance_class         = "db.t3.micro" # Instância leve para testes/estudo
  allocated_storage      = 20
  max_allocated_storage  = 100 # Permite auto-scaling do disco se encher
  db_name                = "flashsales"
  username               = "postgres"
  password               = "sua_senha_super_segura_123" # Em produção, use variáveis!
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot    = true # Apenas para testes (evita travar ao dar destroy)
}

# 5. Réplica de Leitura (Read Replica) para aguentar as consultas da API
resource "aws_db_instance" "replica" {
  identifier             = "flash-sales-db-replica"
  replicate_source_db    = aws_db_instance.master.identifier
  instance_class         = "db.t3.micro"
  skip_final_snapshot    = true
  # A réplica herda o subnet group e a engine automaticamente da origem
}