# Build ECS repo to put images into
resource "aws_ecr_repository" "hub_ecr_repository" {
  name                 = "hub_ecr_repository"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    name      = "hub_ecr_repository"
    terraform = "true"
  }
}

# Policy to permnit inter-account access
resource "aws_ecr_repository_policy" "hub_ecr_repository_policy" {
  repository = aws_ecr_repository.hub_ecr_repository.name

  policy = jsonencode(
    {
      "Version" : "2008-10-17",
      "Statement" : [
        {
          "Sid" : "AllowVeradigmAccountsToPullAdoBuilder",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::bbbbbbbbbb:root"
            ]
          },
          "Action" : [
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:BatchCheckLayerAvailability"
          ]
        }
      ]
    }
  )
}
