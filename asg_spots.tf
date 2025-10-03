# Auto Scaling Group para instâncias Spot
# Gerencia automaticamente o número de instâncias EC2 Spot no cluster (mais baratas)
resource "aws_autoscaling_group" "spots" {
  name_prefix = format("%s-spots", var.project_name)

  # Subnets privadas onde as instâncias serão criadas (multi-AZ)
  vpc_zone_identifier = [
    data.aws_ssm_parameter.subnet_private_1a.value,
    data.aws_ssm_parameter.subnet_private_1b.value,
    data.aws_ssm_parameter.subnet_private_1c.value
  ]

  # Configurações de escala do Auto Scaling Group para instâncias Spot
  desired_capacity = var.cluster_spot_desired_size # Número inicial de instâncias Spot
  max_size         = var.cluster_spot_max_size     # Máximo de instâncias Spot
  min_size         = var.cluster_spot_min_size     # Mínimo de instâncias Spot

  # Launch Template configurado para instâncias Spot
  launch_template {
    id      = aws_launch_template.spots.id
    version = aws_launch_template.spots.latest_version
  }

  # Tag propagada para todas as instâncias Spot criadas
  tag { 
    key                 = "Name"
    value               = format("%s-spots", var.project_name)
    propagate_at_launch = true
  }

  # Tag necessária para integração com ECS
  # Permite que o ECS gerencie este Auto Scaling Group
  tag { 
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }
}

# Capacity Provider para instâncias Spot
# Integra o Auto Scaling Group Spot com o cluster ECS
resource "aws_ecs_capacity_provider" "spot" {
  name = format("%s-spots", var.project_name)
  
  # Configuração do Auto Scaling Group Provider para Spot
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.spots.arn

    # Configurações de escalonamento gerenciado pelo ECS
    managed_scaling {
      maximum_scaling_step_size = 10       # Máximo de instâncias adicionadas por vez
      minimum_scaling_step_size = 1        # Mínimo de instâncias adicionadas por vez
      status                    = "ENABLED" # Escalonamento automático habilitado
      target_capacity           = 90       # Percentual de utilização alvo (90%)
    }
  }
}