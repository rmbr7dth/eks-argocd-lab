terraform {
  # >= 1.15.0: the S3 backend can read `aws login` sessions and supports native
  # S3 state locking (use_lockfile). Older versions fail to find credentials.
  required_version = ">= 1.15.0"

  required_providers {
    # >= 6.23 reads `aws login` sessions; the VPC module v6 needs >= 6.28.
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.28, < 7.0"
    }
  }

  # Partial backend config: bucket and region come from backend.hcl, which
  # scripts/bootstrap.sh generates. Run: terraform init -backend-config=backend.hcl
  backend "s3" {}
}

provider "aws" {
  region = var.region

  # Every taggable resource gets these tags: easy cost tracking and cleanup.
  default_tags {
    tags = {
      Project   = var.cluster_name
      ManagedBy = "terraform"
    }
  }
}
