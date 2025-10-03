#!/bin/bash

# Script de inicialização das instâncias EC2 do cluster ECS
# Este script é executado automaticamente quando uma instância é criada

# Configura o arquivo de configuração do ECS Agent
# Define qual cluster ECS esta instância deve se registrar
echo ECS_CLUSTER=${CLUSTER_NAME} >> /etc/ecs/ecs.config

# Adicione aqui outras configurações necessárias como:
# - Instalação de pacotes adicionais
# - Configurações de segurança
# - Configurações de monitoramento
# - Configurações de logging
