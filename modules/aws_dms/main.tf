# 1. Grupo de subredes para la instancia de replicación
resource "aws_dms_replication_subnet_group" "main" {
  replication_subnet_group_id          = "${var.project_name}-dms-subnets-${var.environment}"
  replication_subnet_group_description = "Subnet group for DMS replication instance"
  subnet_ids                           = var.subnet_ids
}

# 2. Instancia de Replicación
resource "aws_dms_replication_instance" "main" {
  replication_instance_class   = var.replication_instance_class
  replication_instance_id      = "${var.project_name}-replication-instance-${var.environment}"
  allocated_storage            = 20
  apply_immediately            = true
  replication_subnet_group_id  = aws_dms_replication_subnet_group.main.id
  publicly_accessible          = true # Cambiar a false en producción real

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