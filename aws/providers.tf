terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # El backend también usará las credenciales inyectadas por el pipeline
  backend "s3" {
    bucket         = "terraform-multicloud-test"
    key            = "aws/terraform.tfstate"
    region         = "eu-central-1"
    use_lockfile = true
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-central-1"
  # No incluimos access_key ni secret_key aquí por seguridad.
}