# Data sources para recuperar informações de rede do SSM Parameter Store
# Estes parâmetros devem ter sido criados previamente por um módulo de rede

# ID da VPC onde o cluster ECS será criado
data "aws_ssm_parameter" "vpc" {
  name = var.ssm_vpc_id
}

# IDs das subnets públicas (uma por zona de disponibilidade)
# Utilizadas pelo Application Load Balancer
data "aws_ssm_parameter" "subnet_public_1a" {
  name = var.ssm_public_subnet_1
}

data "aws_ssm_parameter" "subnet_public_1b" {
  name = var.ssm_public_subnet_2
}

data "aws_ssm_parameter" "subnet_public_1c" {
  name = var.ssm_public_subnet_3
}

# IDs das subnets privadas (uma por zona de disponibilidade)
# Utilizadas pelas instâncias EC2 do cluster ECS
data "aws_ssm_parameter" "subnet_private_1a" {
  name = var.ssm_private_subnet_1
}

data "aws_ssm_parameter" "subnet_private_1b" {
  name = var.ssm_private_subnet_2
}

data "aws_ssm_parameter" "subnet_private_1c" {
  name = var.ssm_private_subnet_3
}