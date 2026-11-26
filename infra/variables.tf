variable "region" {
  description = "AWS region for every resource in this project."
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name. Also used to name the VPC and tag resources."
  type        = string
  default     = "eks-argocd-lab"
}

variable "kubernetes_version" {
  description = "EKS Kubernetes minor version. 1.36 and 1.37 are both in EKS standard support."
  type        = string
  default     = "1.36"
}

variable "admin_cidr" {
  description = "Your public IPv4 in CIDR form (x.x.x.x/32). Only this range can reach the Kubernetes API from the internet."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.admin_cidr))
    error_message = "admin_cidr must be an IPv4 CIDR, for example 203.0.113.10/32."
  }
}

variable "node_instance_type" {
  description = "EC2 instance type for the managed node group."
  type        = string
  default     = "t3.medium"
}
