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

  create_database_subnet_group = true
  database_subnets             = var.private_subnets # O las que prefieras para la DB

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}