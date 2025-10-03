#### GENERAL CONFIGS ####
# Configurações gerais do projeto

# Nome do projeto - usado como prefixo em todos os recursos
variable "project_name" {}

# Região AWS onde os recursos serão criados
variable "region" {}

# Ambiente (dev, stg, prd, etc.)
variable "environment" {}

#### SSM VPC #####
# Parâmetros do Systems Manager (SSM) para recuperar IDs de rede
# Estes valores são armazenados no SSM Parameter Store por uma infraestrutura de rede pré-existente

# ID da VPC armazenado no SSM Parameter Store
variable "ssm_vpc_id" {}

# IDs das subnets públicas armazenados no SSM (uma por AZ)
variable "ssm_public_subnet_1" {}  # Subnet pública AZ 1a

variable "ssm_public_subnet_2" {}  # Subnet pública AZ 1b

variable "ssm_public_subnet_3" {}  # Subnet pública AZ 1c

# IDs das subnets privadas armazenados no SSM (uma por AZ)
variable "ssm_private_subnet_1" {} # Subnet privada AZ 1a

variable "ssm_private_subnet_2" {} # Subnet privada AZ 1b

variable "ssm_private_subnet_3" {} # Subnet privada AZ 1c

#### BALANCER ####
# Configurações do Application Load Balancer

# Define se o Load Balancer é interno (true) ou voltado para internet (false)
variable "load_balancer_internal" {}

# Tipo do Load Balancer (application, network, gateway)
variable "load_balancer_type" {}

#### ECS General ####
# Configurações das instâncias EC2 que compõem o cluster ECS

# AMI das instâncias EC2 (deve ser uma AMI otimizada para ECS)
variable "nodes_ami" {}

# Tipo de instância EC2 (ex: t3.micro, t3.small, m5.large)
variable "nodes_instace_type" {}

# Tamanho do volume EBS em GB
variable "node_volume_size" {}

# Tipo do volume EBS (gp2, gp3, io1, io2)
variable "node_volume_type" {}

# Configurações do Auto Scaling Group para instâncias On-Demand
variable "cluster_on_demand_min_size" {}     # Mínimo de instâncias

variable "cluster_on_demand_max_size" {}     # Máximo de instâncias

variable "cluster_on_demand_desired_size" {} # Número desejado de instâncias

# Configurações do Auto Scaling Group para instâncias Spot
variable "cluster_spot_min_size" {}          # Mínimo de instâncias Spot

variable "cluster_spot_max_size" {}          # Máximo de instâncias Spot

variable "cluster_spot_desired_size" {}      # Número desejado de instâncias Spot