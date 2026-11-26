output "cluster_name" {
  description = "EKS cluster name."
  value       = var.cluster_name
}

output "region" {
  description = "AWS region."
  value       = var.region
}

output "configure_kubectl" {
  description = "Run this to point kubectl at the cluster."
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}"
}
