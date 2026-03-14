locals {
  env = lookup(var.env_configs, terraform.workspace, null)
}

module "network" {
  source = "../modules/aws_vpc"

  vpc_name           = "vpc-${terraform.workspace}"
  cidr_block         = local.env.cidr
  availability_zones = ["eu-central-1a", "eu-central-1b"]
  
  # Mantenemos 2 públicas para que el DMS Subnet Group no falle (mínimo 2 AZs)
  public_subnets  = [
    cidrsubnet(local.env.cidr, 8, 1), 
    cidrsubnet(local.env.cidr, 8, 2)
  ]
  
  # Ya no necesitas NAT Gateway (ahorro de costos y complejidad en la PoC)
  enable_nat = false
}

module "dms_migration" {
  source             = "../modules/aws_dms"
  project_name       = "sms"
  environment        = terraform.workspace
  
  # DMS usará las subredes donde ahora también estará tu RDS
  subnet_ids         = module.network.public_subnets 
  
  source_db_address  = aws_db_instance.source_db.address
  source_db_username = aws_db_instance.source_db.username
  source_db_password = var.source_db_password

  target_db_address  = aws_db_instance.target_db.address
  target_db_username = aws_db_instance.target_db.username
  target_db_password = var.target_db_password

  table_mappings = jsonencode({
    rules = [{
      rule-type = "selection"
      rule-id   = "1"
      rule-name = "1"
      object-locator = { schema-name = "sms_db", table-name = "co2_emissions" } # Actualizado para tu tabla de SMS
      rule-action = "include"
    }]
  })
}