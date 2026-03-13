variable "source_db_password" {
  description = "Password para la base de datos de origen"
  type        = string
  sensitive   = true
}

variable "target_db_password" {
  description = "Password para la base de datos de destino"
  type        = string
  sensitive   = true
}

variable "env_configs" {
  type = map(object({
    cidr       = string
    enable_nat = bool
  }))
  default = {
    dev  = { cidr = "10.0.0.0/16", enable_nat = false }
    test = { cidr = "10.1.0.0/16", enable_nat = false }
    prod = { cidr = "10.2.0.0/16", enable_nat = true  }
  }
}
