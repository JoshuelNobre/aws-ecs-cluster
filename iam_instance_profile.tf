# Role IAM para as instâncias EC2 do cluster ECS
# Define quais permissões as instâncias terão para interagir com serviços AWS
resource "aws_iam_role" "main" {
  name = format("%s-instance-profile", var.project_name)

  # Política de confiança: permite que instâncias EC2 assumam esta role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"  # Permite que EC2 use esta role
      }
    }]
  })
}

# Anexa política gerenciada para ECS
# Permite que as instâncias se registrem no cluster e executem containers
resource "aws_iam_role_policy_attachment" "ec2_role" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Anexa política para Systems Manager (SSM)
# Permite gerenciamento remoto das instâncias via Session Manager
resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.main.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

# Instance Profile que associa a role IAM às instâncias EC2
# Recurso necessário para que instâncias EC2 usem roles IAM
resource "aws_iam_instance_profile" "main" {
  name = format("%s-instance-profile", var.project_name)
  role = aws_iam_role.main.name
}