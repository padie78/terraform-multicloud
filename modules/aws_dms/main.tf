# 1. Grupo de subredes para la instancia de replicación
resource "aws_dms_replication_subnet_group" "main" {
  replication_subnet_group_id          = "${var.project_name}-subnets-${var.environment}-new"
  replication_subnet_group_description = "Subnet group for DMS"
  subnet_ids                           = var.subnet_ids # Asegúrate que aquí pasas las públicas o privadas correctamente
}

# 2. Instancia de Replicación
resource "aws_dms_replication_instance" "main" {
  # Forzamos la clase t3.micro que es la más estable para Dev
  replication_instance_class   = "dms.t3.small" 
  
  replication_instance_id      = "${var.project_name}-replication-instance-${var.environment}"
  allocated_storage            = 20
  apply_immediately            = true
  
  # Versión del motor de DMS (opcional pero recomendado para estabilidad)
  engine_version               = "3.5.1" 

  replication_subnet_group_id  = aws_dms_replication_subnet_group.main.id
  publicly_accessible          = true 

  # Esto ayuda a que no se quede trabado al intentar borrar la VPC
  # Permite que Terraform espere más tiempo a que AWS suelte las ENIs
  timeouts {
    create = "30m"
    delete = "30m"
  }

  tags = { Name = "${var.project_name}-dms-instance" }
}

# 3. Endpoint Origen
resource "aws_dms_endpoint" "source" {
  endpoint_id   = "${var.project_name}-source-endpoint-${var.environment}"
  endpoint_type = "source"
  engine_name   = "mysql"
  server_name   = var.source_db_address
  port          = var.source_db_port
  username      = var.source_db_username
  password      = var.source_db_password
}

# 4. Endpoint Destino
resource "aws_dms_endpoint" "target" {
  endpoint_id   = "${var.project_name}-target-endpoint-${var.environment}"
  endpoint_type = "target"
  engine_name   = "mysql"
  server_name   = var.target_db_address
  port          = var.target_db_port
  username      = var.target_db_username
  password      = var.target_db_password
}

# 5. Tarea de Replicación
resource "aws_dms_replication_task" "main" {
  replication_task_id      = "${var.project_name}-migration-task-${var.environment}"
  migration_type           = "full-load"
  replication_instance_arn = aws_dms_replication_instance.main.replication_instance_arn
  source_endpoint_arn      = aws_dms_endpoint.source.endpoint_arn
  target_endpoint_arn      = aws_dms_endpoint.target.endpoint_arn
  table_mappings           = var.table_mappings

  lifecycle {
    ignore_changes = [replication_task_settings]
  }
}