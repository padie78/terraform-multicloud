variable "project_name" {
  type        = string
  description = "Nombre del proyecto (ej: sms)"
}

variable "environment" {
  type        = string
  description = "Entorno (ej: dev, prod)"
}

variable "replication_instance_class" {
  type    = string
  default = "dms.t3.micro"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Lista de IDs de subredes donde se desplegará la instancia de replicación"
}

# --- Variables para Source DB ---
variable "source_db_address"  { type = string }
variable "source_db_port" {
  type    = number
  default = 3306
}
variable "source_db_username" { type = string }
variable "source_db_password" {
  type      = string
  sensitive = true
}

# --- Variables para Target DB ---
variable "target_db_address" { type = string }
variable "target_db_port" {
  type    = number
  default = 3306
}
variable "target_db_username" { type = string }
variable "target_db_password" {
  type      = string
  sensitive = true
}

variable "table_mappings" {
  type        = string
  description = "JSON con las reglas de selección de tablas para la migración"
}