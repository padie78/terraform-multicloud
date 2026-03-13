module "vpc_internal" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.cidr_block

  azs             = var.availability_zones # Asegúrate que sean ["eu-central-1a", "eu-central-1b"]
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat
  single_nat_gateway = true

  # DESACTIVAMOS la creación automática para que no choque con las IPs privadas
  create_database_subnet_group = false 
}

# CREACIÓN MANUAL: Esto garantiza que el grupo use las 2 subredes que ya existen
resource "aws_db_subnet_group" "database" {
  name       = "${var.vpc_name}-db-group-fix" # Le cambiamos el nombre para forzar creación nueva
  subnet_ids = module.vpc_internal.private_subnets

  tags = { Name = "${var.vpc_name}-db-group" }
}