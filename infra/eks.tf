module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"

  name               = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # --- API endpoint access ---------------------------------------------------
  # Public endpoint, but only your IP may reach it (v21 defaults public to false).
  endpoint_public_access       = true
  endpoint_public_access_cidrs = [var.admin_cidr]
  # Nodes talk to the API over the private endpoint inside the VPC. Without
  # this, nodes (egressing via the NAT IP) would be blocked by the CIDR list
  # above and never join. It is already the module default; set explicitly
  # because the cluster breaks without it.
  endpoint_private_access = true

  # --- Who can use kubectl -----------------------------------------------------
  # Grants the IAM identity running Terraform cluster-admin via an EKS Access
  # Entry (the replacement for the deprecated aws-auth ConfigMap).
  # v21 defaults this to false -> you would get "Unauthorized" from kubectl.
  enable_cluster_creator_admin_permissions = true

  # --- Networking --------------------------------------------------------------
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # --- EKS managed add-ons (AWS installs and patches these) --------------------
  addons = {
    vpc-cni = {
      # Create the CNI before the node group so nodes come up with pod networking.
      before_compute = true
    }
    kube-proxy = {}
    coredns    = {}
  }

  # --- Worker nodes ------------------------------------------------------------
  eks_managed_node_groups = {
    default = {
      # Amazon Linux 2023 (AL2 AMIs are no longer published for EKS).
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = [var.node_instance_type]

      min_size     = 2
      max_size     = 3
      desired_size = 2
    }
  }
}
