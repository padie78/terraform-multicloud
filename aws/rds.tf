# --- SECURITY GROUP PARA LAS DBs ---
# Permite que el DMS y tú (desde fuera) se conecten a las bases de datos
resource "aws_security_group" "rds_sg" {
  name        = "rds-migration-sg"
  description = "Permitir trafico MySQL"
  vpc_id      = module.vpc.vpc_id # Viene de tu modulo VPC

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # En prod, solo permite la IP de DMS y la tuya
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- BASE DE DATOS ORIGEN (SOURCE) ---
resource "aws_db_instance" "source_db" {
  identifier           = "source-db-migration"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage     = 20
  db_name              = "mydb"
  username             = "admin"
  password             = "PasswordSeguro123"
  parameter_group_name = "default.mysql8.0"
  
  # Importante para que DMS pueda leer los logs de replicacion
  backup_retention_period = 1 
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = module.vpc.database_subnet_group # Usamos las subnets del modulo VPC
  publicly_accessible    = true
  skip_final_snapshot    = true
}

# --- BASE DE DATOS DESTINO (TARGET) ---
resource "aws_db_instance" "target_db" {
  identifier           = "target-db-migration"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  allocated_storage     = 20
  db_name              = "targetdb"
  username             = "admin"
  password             = "PasswordSeguro123"
  parameter_group_name = "default.mysql8.0"
  
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = module.vpc.database_subnet_group
  publicly_accessible    = true
  skip_final_snapshot    = true
}