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

module "dms_migration" {
  source             = "./modules/aws_dms"
  project_name       = "sms"
  environment        = terraform.workspace
  subnet_ids         = module.vpc.public_subnets # Usamos las subredes que vienen del módulo VPC
  
  source_db_address  = aws_db_instance.source_db.address
  source_db_username = "admin"
  source_db_password = "PasswordSeguro123"

  target_db_address  = aws_db_instance.target_db.address
  target_db_username = "admin"
  target_db_password = "PasswordSeguro123"

  table_mappings = jsonencode({
    rules = [{
      rule-type = "selection"
      rule-id   = "1"
      rule-name = "1"
      object-locator = { schema-name = "mydb", table-name = "users" }
      rule-action = "include"
    }]
  })
}