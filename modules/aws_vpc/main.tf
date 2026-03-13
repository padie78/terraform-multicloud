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

  # --- CORRECCIÓN AQUÍ ---
  # Activamos el grupo, pero le decimos que use las subredes privadas que ya existen
  create_database_subnet_group = true
  create_database_subnet_route_table = false 
  # No definimos 'database_subnets' aquí para que no intente crear nuevas IPs que choquen
  
  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}