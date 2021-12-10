resource "aws_iam_role" "SpokeABuilderExecutionRole" {
  name = "SpokeABuilderExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name      = "SpokeABuilderExecutionRole"
    Terraform = "true"
  }
}

# Link to AWS-managed policy - AmazonECSTaskExecutionRolePolicy
resource "aws_iam_role_policy_attachment" "SpokeABuilderExecutionRole_to_ecsTaskExecutionRole" {
  role       = aws_iam_role.SpokeABuilderExecutionRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Set inline policy to permit secrets management reading
resource "aws_iam_role_policy" "SpokeABuilderExecutionRoleSsmRead" {
  name   = "SpokeABuilderExecutionRoleSsmRead"
  role   = aws_iam_role.SpokeABuilderExecutionRole.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue"
          ],
          "Resource" : [
            "arn:aws:secretsmanager:us-east-1:aaaaaaaaaaa:secret:SecretName*" <-- Note the "*" at the end, this is required, the ARN in the Hub account
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt"
          ],
          "Resource" : [
            "arn:aws:kms:us-east-1:aaaaaaaa:key/1111111-22222-33333-444444444444" <-- The ARN of the key in the Hub account
          ]
        }
      ]
    }
  )
}