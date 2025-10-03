# Security Group principal para as instâncias EC2 do cluster ECS
# Controla o tráfego de rede das instâncias que executam os containers
resource "aws_security_group" "main" {
  name   = format("%s", var.project_name)
  vpc_id = data.aws_ssm_parameter.vpc.value

  # Regra de saída: permite todo tráfego de saída
  # Necessário para que as instâncias possam baixar imagens Docker, atualizações, etc.
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

# Regra de entrada permitindo comunicação interna da VPC
# Permite que recursos dentro da VPC (ALB, outras instâncias) se comuniquem com as instâncias ECS
resource "aws_security_group_rule" "subnet_ranges" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "ingress"
  description       = "Liberando trafego para VPC"
  security_group_id = aws_security_group.main.id
  cidr_blocks       = ["10.0.0.0/16"]  # Range da VPC
}