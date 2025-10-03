# Security Group para o Load Balancer
# Controla o tráfego de entrada e saída do ALB
resource "aws_security_group" "lb" {
  name   = format("%s-load-balancer", var.project_name)
  vpc_id = data.aws_ssm_parameter.vpc.value

  # Regra de saída: permite todo tráfego de saída (necessário para que o ALB encaminhe requisições para os targets)
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}

# Regra de entrada para tráfego HTTP na porta 80
# Permite que qualquer IP da internet acesse o Load Balancer via HTTP
resource "aws_security_group_rule" "ingress_80" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 80
  to_port           = 80
  description       = "Liberando trafego na porta 80"
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
}

# Regra de entrada para tráfego HTTPS na porta 443
# Permite que qualquer IP da internet acesse o Load Balancer via HTTPS
resource "aws_security_group_rule" "ingress_443" {
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 443
  to_port           = 443
  description       = "Liberando trafego na porta 443"
  protocol          = "tcp"
  security_group_id = aws_security_group.lb.id
  type              = "ingress"
}

# Application Load Balancer (ALB) principal
# Distribui o tráfego de entrada entre as instâncias do ECS nas múltiplas AZs
resource "aws_lb" "main" {
  name               = format("%s-ingress", var.project_name)
  internal           = var.load_balancer_internal    # Define se é interno (VPC) ou externo (internet-facing)
  load_balancer_type = var.load_balancer_type        # Tipo do LB (application, network, etc.)

  # Subnets públicas onde o ALB será deployado (multi-AZ para alta disponibilidade)
  subnets = [
    data.aws_ssm_parameter.subnet_public_1a.value,
    data.aws_ssm_parameter.subnet_public_1b.value,
    data.aws_ssm_parameter.subnet_public_1c.value
  ]

  # Security Groups que controlam o tráfego do ALB
  security_groups = [
    aws_security_group.lb.id
  ]

  enable_cross_zone_load_balancing = false  # Balanceamento entre zonas (false = mais eficiente em custos)
  enable_deletion_protection       = false  # Proteção contra exclusão acidental
}

# Listener do Load Balancer para a porta 80
# Define como o ALB deve processar as requisições HTTP recebidas
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"      # Porta onde o ALB escuta as requisições
  protocol          = "HTTP"    # Protocolo utilizado
  
  # Ação padrão quando nenhuma regra específica for atendida
  default_action {
    type = "fixed-response"      # Retorna uma resposta fixa
    fixed_response {
      content_type = "text/plain"
      message_body = "LinuxTips" # Mensagem padrão retornada
      status_code  = "200"       # Código HTTP de sucesso
    }
  }
}