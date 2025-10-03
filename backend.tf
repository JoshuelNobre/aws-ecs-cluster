# Configuração do backend remoto para armazenar o estado do Terraform
# O estado será armazenado no Amazon S3
# Parâmetros específicos são definidos no arquivo backend.tfvars
terraform {
  backend "s3" {
    # Configurações serão fornecidas via arquivo .tfvars ou linha de comando
  }
}