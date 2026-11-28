resource "aws_ecr_repository" "demo" {
  name                 = "demo-app"
  image_tag_mutability = "IMMUTABLE" # once pushed, a tag can never be overwritten

  image_scanning_configuration {
    scan_on_push = true # AWS scans every image for CVEs automatically
  }
}

# Keep only the last 20 images — older ones are deleted automatically
resource "aws_ecr_lifecycle_policy" "demo" {
  repository = aws_ecr_repository.demo.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 20 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 20
      }
      action = { type = "expire" }
    }]
  })
}

