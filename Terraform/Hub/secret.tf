# Create secret to store the secret value
resource "aws_secretsmanager_secret" "hub_ado_join_pak" {
  name       = "AzureDevOps_JoinBuildPool_PAK"
  kms_key_id = aws_kms_key.hub_secrets_manager_cmk.arn

  tags = {
    Terraform = "true"
  }
}

# Policy to permit multi-account access
resource "aws_secretsmanager_secret_policy" "hub_ado_join_pak" {
  secret_arn = aws_secretsmanager_secret.hub_ado_join_pak.arn
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [{
        "Sid" : "AzureDevOpsBuildersSecretsAccess",
        "Effect" : "Allow",
        "Action" : "secretsmanager:GetSecretValue",
        "Resource" : "*",
        "Principal" : {
          "AWS" : [
            "arn:aws:iam::bbbbbbbbbb:role/SpokeABuilderExecutionRole"
          ]
        }
      }]
  })
}
