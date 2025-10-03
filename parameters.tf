# Parâmetro SSM para armazenar o ARN do Load Balancer
# Permite que outros módulos/stacks referenciem o Load Balancer criado
resource "aws_ssm_parameter" "lb_arn" {
  name  = "/linuxtips/ecs/lb/id"
  value = aws_lb.main.arn
  type  = "String"
}

# Parâmetro SSM para armazenar o ARN do Listener do Load Balancer
# Permite que aplicações adicionem regras de roteamento ao listener existente
resource "aws_ssm_parameter" "lb_listener" {
  name  = "/linuxtips/ecs/lb/listener"
  value = aws_lb_listener.main.arn
  type  = "String"
}