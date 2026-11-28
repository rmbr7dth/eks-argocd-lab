output "ecr_repository_url" {
  description = "Push images here: docker push <url>:<tag>"
  value       = aws_ecr_repository.demo.repository_url
}

output "ecr_repository_arn" {
  description = "ECR repo ARN."
  value       = aws_ecr_repository.demo.arn
}

output "github_ci_role_arn" {
  description = "Paste this into your CD workflow as role-to-assume."
  value       = aws_iam_role.github_ci.arn
}

output "configure_cd" {
  description = "Values to paste into your GitHub Actions CD workflow."
  value = {
    role_to_assume = aws_iam_role.github_ci.arn
    ecr_registry   = split("/", aws_ecr_repository.demo.repository_url)[0]
    ecr_repository = aws_ecr_repository.demo.name
  }
}

