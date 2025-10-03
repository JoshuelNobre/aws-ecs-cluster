# Auto Scaling Group para instâncias On-Demand
# Gerencia automaticamente o número de instâncias EC2 On-Demand no cluster
resource "aws_autoscaling_group" "on-demand" {
  name_prefix = format("%s-on-demand", var.project_name)

  # Subnets privadas onde as instâncias serão criadas (multi-AZ)
  vpc_zone_identifier = [
    data.aws_ssm_parameter.subnet_private_1a.value,
    data.aws_ssm_parameter.subnet_private_1b.value,
    data.aws_ssm_parameter.subnet_private_1c.value
  ]

  # Configurações de escala do Auto Scaling Group
  desired_capacity = var.cluster_on_demand_desired_size # Número inicial de instâncias
  max_size         = var.cluster_on_demand_max_size     # Máximo de instâncias
  min_size         = var.cluster_on_demand_min_size     # Mínimo de instâncias

  # Launch Template que define a configuração das instâncias
  launch_template {
    id      = aws_launch_template.on_demand.id
    version = aws_launch_template.on_demand.latest_version
  }

  # Tag propagada para todas as instâncias criadas
  tag { 
    key                 = "Name"
    value               = format("%s-on-demand", var.project_name)
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

# Capacity Provider para instâncias On-Demand
# Integra o Auto Scaling Group com o cluster ECS para escalonamento automático
resource "aws_ecs_capacity_provider" "on_demand" {
  name = format("%s-on-demand", var.project_name)
  
  # Configuração do Auto Scaling Group Provider
  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.on-demand.arn

    # Configurações de escalonamento gerenciado pelo ECS
    managed_scaling {
      maximum_scaling_step_size = 10       # Máximo de instâncias adicionadas por vez
      minimum_scaling_step_size = 1        # Mínimo de instâncias adicionadas por vez
      status                    = "ENABLED" # Escalonamento automático habilitado
      target_capacity           = 90       # Percentual de utilização alvo (90%)
    }
  }
}