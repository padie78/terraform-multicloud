module "vpc_internal" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.cidr_block

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat
  single_nat_gateway = true

  # 1. DESACTIVA la creación automática para evitar el conflicto de IPs
  create_database_subnet_group = false 

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

# 2. CREA EL GRUPO MANUALMENTE usando las subredes privadas ya creadas
# Esto cumple con el requisito de 2 AZs de RDS y DMS sin duplicar subredes.
resource "aws_db_subnet_group" "database" {
  name       = "${var.vpc_name}-db-group"
  # Tomamos los IDs de las subredes privadas que el módulo ya creó exitosamente
  subnet_ids = module.vpc_internal.private_subnets

  tags = {
    Name        = "${var.vpc_name}-db-group"
    Environment = terraform.workspace
  }
}