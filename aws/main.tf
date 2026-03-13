locals {
  # El pipeline selecciona el workspace. Si no existe en el mapa, falla aquí.
  env = lookup(var.env_configs, terraform.workspace, null)
}

module "network" {
  source = "../modules/aws_vpc"

  vpc_name   = "vpc-${terraform.workspace}"
  cidr_block = local.env.cidr
  
  availability_zones = ["eu-central-1a", "eu-central-1b"]
  
  # Subnetting calculado dinámicamente
  private_subnets = [cidrsubnet(local.env.cidr, 4, 1)]
  public_subnets  = [cidrsubnet(local.env.cidr, 4, 2)]
  
  # Inyección de dependencia desde el mapa de variables
  enable_nat = local.env.enable_nat
}