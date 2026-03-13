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
    bucket         = "tu-terraform-state-bucket" # Cámbialo por tu bucket real
    key            = "aws/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "us-east-1"
  # No incluimos access_key ni secret_key aquí por seguridad.
}