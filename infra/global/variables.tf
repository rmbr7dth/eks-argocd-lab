variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "github_org" {
  description = "Your GitHub username (e.g. rmbr7dth)"
  type        = string
}

variable "github_repo" {
  description = "Your repo name (e.g. eks-argocd-lab)"
  type        = string
  default     = "eks-argocd-lab"
}

