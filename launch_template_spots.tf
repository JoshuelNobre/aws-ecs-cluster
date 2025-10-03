# Launch Template para instâncias Spot
# Similar ao template On-Demand, mas configurado para usar instâncias Spot (mais baratas)
resource "aws_launch_template" "spots" {
  name_prefix = format("%s-spots", var.project_name)
  image_id    = var.nodes_ami          # AMI otimizada para ECS

  instance_type = var.nodes_instace_type # Tipo da instância

  # Security Groups aplicados às instâncias
  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

  # Configuração específica para instâncias Spot
  instance_market_options {
    market_type = "spot"         # Tipo de mercado: Spot Instances
    spot_options {
      max_price = "0.15"         # Preço máximo por hora (USD)
    }
  }

  # Instance Profile com permissões IAM necessárias
  iam_instance_profile {
    name = aws_iam_instance_profile.main.name
  }

  # Sempre usa a versão mais recente do template
  update_default_version = true

  # Configuração do disco EBS
  block_device_mappings {
    device_name = "/dev/xvda"  # Dispositivo raiz do sistema

    ebs {
      volume_size = var.node_volume_size # Tamanho em GB
      volume_type = var.node_volume_type # Tipo do volume
    }
  }

  # Tags aplicadas às instâncias criadas
  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = var.environment,
      Name = format("%s-on-demand", var.project_name) # NOTA: tag inconsistente, deveria ser "spots"
    }
  }

  # Script de inicialização (user-data)
  # Configura a instância para se registrar no cluster ECS
  user_data = base64encode(templatefile("${path.module}/templates/user-data.tpl", {
    CLUSTER_NAME = var.project_name
  }))
}