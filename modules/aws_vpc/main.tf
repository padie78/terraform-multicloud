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

  # --- CORRECCIÓN APLICADA ---
  create_database_subnet_group = true
  
  # Al pasarle var.private_subnets, el grupo incluirá las subredes de ambas AZs
  # que definiste en tu main.tf raíz.
  database_subnets             = var.private_subnets 
  
  # Esto evita que se creen tablas de ruteo adicionales (mantiene todo limpio)
  create_database_subnet_route_table = false 
  
  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}