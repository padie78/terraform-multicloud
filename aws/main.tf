locals {
  # El pipeline selecciona el workspace. Si no existe en el mapa, falla aquí.
  env = lookup(var.env_configs, terraform.workspace, null)
}

module "network" {
  # CORRECCIÓN: Ruta relativa si el archivo está en la raíz de la carpeta 'aws'
  source = "../modules/aws_vpc"

  vpc_name   = "vpc-${terraform.workspace}"
  cidr_block = local.env.cidr
  
  # CORRECCIÓN: Definimos 2 AZs para cumplir con el requisito de AWS DMS
  availability_zones = ["eu-central-1a", "eu-central-1b"]
  
  # CORRECCIÓN: Subnetting con prefijo 8 para evitar solapamiento (ej: 10.0.1.0/24, 10.0.2.0/24, etc.)
  # Se generan 2 privadas y 2 públicas para asegurar el "2 item minimum" de DMS
  private_subnets = [
    cidrsubnet(local.env.cidr, 8, 1), 
    cidrsubnet(local.env.cidr, 8, 2)
  ]
  public_subnets  = [
    cidrsubnet(local.env.cidr, 8, 101), 
    cidrsubnet(local.env.cidr, 8, 102)
  ]
  
  # Inyección de dependencia desde el mapa de variables
  enable_nat = local.env.enable_nat
}

module "dms_migration" {
  # CORRECCIÓN: Ruta relativa ajustada
  source             = "../modules/aws_dms"
  project_name       = "sms"
  environment        = terraform.workspace
  
  # CORRECCIÓN: Referencia al nombre correcto del módulo ('network')
  subnet_ids         = module.network.public_subnets 
  
  # Referencia dinámica a las instancias creadas en rds.tf
  source_db_address  = aws_db_instance.source_db.address
  source_db_username = aws_db_instance.source_db.username
  source_db_password = var.source_db_password # Se recomienda usar variables para passwords

  target_db_address  = aws_db_instance.target_db.address
  target_db_username = aws_db_instance.target_db.username
  target_db_password = var.target_db_password

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