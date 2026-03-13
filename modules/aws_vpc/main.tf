module "vpc_internal" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = var.vpc_name
  cidr = var.cidr_block

  azs             = var.availability_zones
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_nat_gateway = var.enable_nat
  single_nat_gateway = true

  tags = {
    Environment = terraform.workspace
    ManagedBy   = "Terraform"
  }
}

output "vpc_id" { value = module.vpc_internal.vpc_id }