# Cluster ECS principal
# Orquestra e gerencia containers Docker em instâncias EC2
resource "aws_ecs_cluster" "main" {
  name = var.project_name

  # Habilita Container Insights para monitoramento avançado
  # Fornece métricas detalhadas sobre performance dos containers
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# Configuração dos Capacity Providers para o cluster ECS
# Gerencia como o cluster escala adicionando/removendo instâncias
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name
  
  # Lista de capacity providers disponíveis (On-Demand e Spot)
  capacity_providers = [
    aws_ecs_capacity_provider.on_demand.name,
    aws_ecs_capacity_provider.spot.name
  ]

  # Estratégia padrão: usar apenas instâncias On-Demand
  # weight=100 significa 100% das tarefas vão para On-Demand por padrão
  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.on_demand.name
    weight            = 100  # Peso relativo na distribuição de tarefas
    base              = 0    # Número mínimo de tarefas neste provider
  }
}