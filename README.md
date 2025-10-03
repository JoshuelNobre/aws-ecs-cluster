# 🚀 AWS ECS Cluster com Terraform

Este projeto cria um cluster ECS (Elastic Container Service) na AWS usando Terraform, com uma arquitetura híbrida que combina instâncias On-Demand e Spot para otimizar custos e garantir alta disponibilidade.

## 📋 Índice

- [Arquitetura](#-arquitetura)
- [Recursos Criados](#-recursos-criados)
- [Pré-requisitos](#-pré-requisitos)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Configuração](#-configuração)
- [Deploy](#-deploy)
- [Variáveis](#-variáveis)
- [Outputs](#-outputs)
- [Custos](#-custos)
- [Troubleshooting](#-troubleshooting)
- [Limpeza](#-limpeza)

## 🏗️ Arquitetura

### Visão Geral
```
Internet Gateway
       │
   ┌───▼───┐
   │  ALB  │ (Public Subnets)
   └───┬───┘
       │
   ┌───▼───────────────────────────────┐
   │        ECS Cluster                │
   │  ┌─────────────┐ ┌─────────────┐  │ (Private Subnets)
   │  │ On-Demand   │ │ Spot        │  │
   │  │ Instances   │ │ Instances   │  │
   │  └─────────────┘ └─────────────┘  │
   └───────────────────────────────────┘
```

### Componentes Principais

- **🌐 Application Load Balancer**: Ponto de entrada público
- **🔒 VPC com Subnets Privadas/Públicas**: Isolamento de rede
- **⚡ Cluster ECS Híbrido**: Combinação On-Demand + Spot
- **📊 Auto Scaling Groups**: Escalamento automático
- **🛡️ Security Groups**: Controle de tráfego
- **📈 Container Insights**: Monitoramento avançado

## 🎯 Recursos Criados

### Networking
- Application Load Balancer (ALB)
- Security Groups para ALB e instâncias EC2
- Listeners HTTP/HTTPS

### Compute
- Cluster ECS com Container Insights
- Launch Templates para On-Demand e Spot
- Auto Scaling Groups com managed scaling
- Capacity Providers (On-Demand e Spot)

### IAM
- Role para instâncias EC2
- Instance Profile com políticas ECS e SSM
- Políticas para gerenciamento de containers

### Monitoramento
- Container Insights habilitado
- SSM Parameters para integração

## 📋 Pré-requisitos

1. **Infraestrutura de Rede Existente**: 
   - VPC configurada
   - Subnets públicas e privadas
   - IDs armazenados no SSM Parameter Store

2. **Ferramentas**:
   ```bash
   # Terraform
   terraform --version  # >= 1.0
   
   # AWS CLI
   aws --version
   aws configure  # Credenciais configuradas
   ```

3. **Permissões AWS**:
   - ECS Full Access
   - EC2 Full Access
   - IAM permissions
   - SSM Parameter Store access
   - Application Load Balancer permissions

## 📁 Estrutura do Projeto

```
aws-ecs-cluster/
├── 📝 README.md                    # Documentação
├── ⚙️ providers.tf                # Configuração AWS
├── 🗃️ backend.tf                  # Estado remoto S3
├── 📊 variables.tf                # Variáveis de entrada
├── 🔍 data.tf                     # Data sources SSM
├── 🌐 load_balancer.tf            # ALB e listeners
├── 🛡️ sg.tf                       # Security Groups
├── 🚀 ecs.tf                      # Cluster ECS
├── 🔐 iam_instance_profile.tf     # Roles IAM
├── 📋 launch_template.tf          # Template On-Demand
├── 💰 launch_template_spots.tf    # Template Spot
├── 📈 asg.tf                      # ASG On-Demand
├── 💸 asg_spots.tf               # ASG Spot
├── 📤 output.tf                   # Outputs
├── 🗂️ parameters.tf               # SSM Parameters
├── 📂 environment/
│   └── dev/
│       ├── backend.tfvars         # Config backend
│       └── terraform.tfvars       # Valores das variáveis
└── 📄 templates/
    └── user-data.tpl              # Script inicialização
```

## ⚙️ Configuração

### 1. Configurar Backend
Edite o arquivo `environment/dev/backend.tfvars`:
```hcl
bucket  = "meu-bucket-terraform-state"
key     = "ecs-cluster/terraform.tfstate"
region  = "us-east-1"
encrypt = true
```

### 2. Configurar Variáveis
Edite o arquivo `environment/dev/terraform.tfvars`:
```hcl
# Configurações Gerais
project_name = "meu-projeto"
region       = "us-east-1"

# SSM Parameters (VPC existente)
ssm_vpc_id              = "/vpc/vpc-id"
ssm_public_subnet_1     = "/vpc/public-subnet-1a"
ssm_public_subnet_2     = "/vpc/public-subnet-1b"
ssm_public_subnet_3     = "/vpc/public-subnet-1c"
ssm_private_subnet_1    = "/vpc/private-subnet-1a"
ssm_private_subnet_2    = "/vpc/private-subnet-1b"
ssm_private_subnet_3    = "/vpc/private-subnet-1c"

# Load Balancer
load_balancer_internal = false
load_balancer_type     = "application"

# Instâncias EC2
nodes_ami           = "ami-0abcdef1234567890"  # AMI ECS-optimized
nodes_instace_type  = "t3.micro"
node_volume_size    = 30
node_volume_type    = "gp3"

# Auto Scaling - On-Demand
cluster_on_demand_min_size     = 1
cluster_on_demand_max_size     = 5
cluster_on_demand_desired_size = 2

# Auto Scaling - Spot
cluster_spot_min_size     = 0
cluster_spot_max_size     = 10
cluster_spot_desired_size = 2
```

## 🚀 Deploy

### 1. Inicializar Terraform
```bash
# Navegue até o diretório do projeto
cd aws-ecs-cluster

# Inicialize o Terraform
terraform init -backend-config="environment/dev/backend.tfvars"
```

### 2. Planejar Deployment
```bash
# Visualize o que será criado
terraform plan -var-file="environment/dev/terraform.tfvars"
```

### 3. Aplicar Configuração
```bash
# Execute o deployment
terraform apply -var-file="environment/dev/terraform.tfvars"
```

### 4. Verificar Recursos
```bash
# Listar outputs
terraform output

# Verificar no AWS Console
aws ecs list-clusters
aws elbv2 describe-load-balancers
```

## 📊 Variáveis

### Configurações Essenciais

| Variável | Tipo | Descrição | Exemplo |
|----------|------|-----------|---------|
| `project_name` | string | Nome do projeto (prefixo recursos) | `"meu-ecs-cluster"` |
| `region` | string | Região AWS | `"us-east-1"` |
| `nodes_ami` | string | AMI otimizada para ECS | `"ami-0abcdef1234567890"` |
| `nodes_instace_type` | string | Tipo da instância EC2 | `"t3.micro"` |

### Auto Scaling

| Variável | Descrição | Recomendado |
|----------|-----------|-------------|
| `cluster_on_demand_desired_size` | Instâncias On-Demand iniciais | `1-2` |
| `cluster_spot_desired_size` | Instâncias Spot iniciais | `2-5` |
| `cluster_on_demand_max_size` | Máximo On-Demand | `5-10` |
| `cluster_spot_max_size` | Máximo Spot | `10-20` |

## 📤 Outputs

Após o deployment, você terá acesso a:

```bash
# DNS do Load Balancer
load_balancer_dns = "meu-projeto-ingress-123456789.us-east-1.elb.amazonaws.com"

# Parâmetros SSM criados
lb_ssm_arn = "/linuxtips/ecs/lb/id"
lb_ssm_listener = "/linuxtips/ecs/lb/listener"
```

### Como usar os outputs:
```bash
# Acessar aplicação
curl http://$(terraform output -raw load_balancer_dns)

# Usar em outros módulos Terraform
data "aws_ssm_parameter" "lb_arn" {
  name = "load_balancer_arn_output_aqui"
}
```

## 💰 Custos

### Estimativa Mensal (us-east-1)

| Recurso | Configuração | Custo Aproximado |
|---------|--------------|------------------|
| **ALB** | 1 ALB + LCU | ~$16-25/mês |
| **EC2 On-Demand** | 2x t3.micro | ~$17/mês |
| **EC2 Spot** | 2x t3.micro | ~$3-5/mês |
| **EBS** | 4x 30GB gp3 | ~$10/mês |
| **Data Transfer** | Variável | ~$5-15/mês |
| **TOTAL** | | **~$51-72/mês** |

### 💡 Dicas para Economia:
- Use mais instâncias Spot que On-Demand
- Configure `target_capacity` para 80-90%
- Monitore uso com Container Insights
- Use Reserved Instances para workloads previsíveis

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Instâncias não se registram no cluster
```bash
# Verificar logs do ECS Agent
aws ssm start-session --target instance-id
sudo docker logs ecs-agent
```

#### 2. ALB não acessa instâncias
- Verificar Security Groups
- Confirmar target group health
- Verificar rotas das subnets

#### 3. Spot instances terminando frequentemente
- Aumentar `max_price` no launch template
- Diversificar tipos de instância
- Usar Spot Fleet Request

### Comandos Úteis

```bash
# Status do cluster
aws ecs describe-clusters --clusters nome-do-cluster

# Instâncias registradas
aws ecs list-container-instances --cluster nome-do-cluster

# Logs do Auto Scaling
aws autoscaling describe-auto-scaling-groups

# Health checks do ALB
aws elbv2 describe-target-health --target-group-arn arn:aws:...
```

## 🧹 Limpeza

### Remover Recursos
```bash
# Destruir toda a infraestrutura
terraform destroy -var-file="environment/dev/terraform.tfvars"

# Confirmar remoção
# Digite 'yes' quando solicitado
```

### ⚠️ Importante:
- Backup dados importantes antes da destruição
- Verifique se não há tarefas ECS rodando
- Confirme que todos os recursos foram removidos no Console AWS

## 📚 Referências

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ECS-Optimized AMIs](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html)
- [Spot Instance Best Practices](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-best-practices.html)

## 🤝 Contribuição

1. Fork este repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para detalhes.

---

**Desenvolvido com ❤️ para a comunidade DevOps**