# Launch Template para instâncias On-Demand
# Define a configuração base das instâncias EC2 que serão criadas pelo Auto Scaling Group
resource "aws_launch_template" "on_demand" {
  name_prefix = format("%s-on-demand", var.project_name)
  image_id    = var.nodes_ami          # AMI otimizada para ECS

  instance_type = var.nodes_instace_type # Tipo da instância (ex: t3.micro)

  # Security Groups aplicados às instâncias
  vpc_security_group_ids = [
    aws_security_group.main.id
  ]

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
      volume_type = var.node_volume_type # Tipo do volume (gp2, gp3, etc.)
    }
  }

  # Tags aplicadas às instâncias criadas
  tag_specifications {
    resource_type = "instance"
    tags = {
      Environment = var.environment,
      Name = format("%s-on-demand", var.project_name)
    }
  }

  # Script de inicialização (user-data)
  # Configura a instância para se registrar no cluster ECS
  user_data = base64encode(templatefile("${path.module}/templates/user-data.tpl", {
    CLUSTER_NAME = var.project_name
  }))
}