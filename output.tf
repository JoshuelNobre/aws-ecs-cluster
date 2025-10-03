# DNS name do Load Balancer
# URL pública para acessar as aplicações hospedadas no cluster
output "load_balancer_dns" {
  value = aws_lb.main.dns_name
}

# ID do parâmetro SSM que contém o ARN do Load Balancer
# Útil para referência em outros módulos Terraform
output "lb_ssm_arn" {
  value = aws_ssm_parameter.lb_arn.id
}

# ID do parâmetro SSM que contém o ARN do Listener
# Útil para adicionar regras de roteamento em outros módulos
output "lb_ssm_listener" {
  value = aws_ssm_parameter.lb_listener.id
}