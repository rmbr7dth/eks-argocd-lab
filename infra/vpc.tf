data "aws_availability_zones" "available" {
  # Only standard AZs (skips Local Zones and other opt-in zones).
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

# EKS needs subnets in at least 2 AZs; 2 keeps the lab small.
locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.cluster_name}-vpc"
  cidr = local.vpc_cidr
  azs  = local.azs

  # Private /20s (10.0.0.0/20, 10.0.16.0/20): nodes and pods live here.
  # The VPC CNI gives every pod a real VPC IP, so private subnets get the big ranges.
  private_subnets = [for i, az in local.azs : cidrsubnet(local.vpc_cidr, 4, i)]

  # Public /24s (10.0.48.0/24, 10.0.49.0/24): only the NAT gateway (and any
  # future internet-facing load balancer) lives here.
  public_subnets = [for i, az in local.azs : cidrsubnet(local.vpc_cidr, 8, i + 48)]

  # Private nodes reach the internet (image pulls, AWS APIs) through NAT.
  enable_nat_gateway = true
  single_nat_gateway = true # Lab: 1 NAT to save cost. Production: one per AZ.

  # Tags that tell Kubernetes load balancer controllers which subnets to use.
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
