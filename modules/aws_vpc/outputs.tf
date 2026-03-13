output "vpc_id" {
  description = "El ID de la VPC"
  value       = module.vpc_internal.vpc_id
}

output "public_subnets" {
  description = "Lista de IDs de las subredes públicas"
  value       = module.vpc_internal.public_subnets
}

output "private_subnets" {
  description = "Lista de IDs de las subredes privadas"
  value       = module.vpc_internal.private_subnets
}

output "database_subnet_group" {
  description = "Nombre del grupo de subredes para la base de datos"
  value       = module.vpc_internal.database_subnet_group_name
}