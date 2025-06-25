provider "aws" {
  region = "eu-central-1"
}

terraform {
  required_version = ">= 0.12.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }

  backend "s3" {
    bucket       = "exampletodo-terraform-state-bucket"
    key          = "terraform/state"
    region       = "eu-central-1"
    use_lockfile = false
  }
}