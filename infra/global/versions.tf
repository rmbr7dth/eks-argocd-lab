terraform {
  required_version = ">= 1.15.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28, < 7.0"
    }
  }

  # Same S3 bucket as infra/ — but a DIFFERENT key
  # so the two states never collide
  backend "s3" {}
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "eks-argocd-lab"
      ManagedBy = "terraform"
    }
  }
}

