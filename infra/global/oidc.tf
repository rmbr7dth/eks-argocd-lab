# ─────────────────────────────────────────────────────────────────
# GitHub OIDC provider — account-wide singleton, already exists.
# We READ it (data source), we do NOT own it.
# Destroying this stack will NEVER delete the provider.
# Linux analogy: this is `id username`, not `useradd username`
# ─────────────────────────────────────────────────────────────────
data "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
}

# The IAM role GitHub Actions will assume
resource "aws_iam_role" "github_ci" {
  name = "github-ci-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Federated = data.aws_iam_openid_connect_provider.github.arn } # ← data. not resource.
      Action    = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_org}/${var.github_repo}:ref:refs/heads/main"
        }
      }
    }]
  })
}

# What the CI role is allowed to do — ECR push only, nothing else
resource "aws_iam_role_policy" "github_ci_ecr" {
  name = "ecr-push"
  role = aws_iam_role.github_ci.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = aws_ecr_repository.demo.arn
      }
    ]
  })
}

