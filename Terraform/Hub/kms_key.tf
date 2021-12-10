resource "aws_kms_alias" "hub_secrets_manager_cmk_alias" {
  name          = "alias/hub_secrets_manager_cmk"
  target_key_id = aws_kms_key.hub_secrets_manager_cmk.key_id
}

resource "aws_kms_key" "hub_secrets_manager_cmk" {
  description = "KMS CMK for Secrets Manager"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Id" : "auto-secretsmanager-2",
      "Statement" : [
        {
          "Sid" : "Enable IAM User Permissions",
          "Effect" : "Allow",
          "Principal" : {
            "AWS" : "arn:aws:iam::aaaaaaaaaaa:root" #Root account ARN (remember to remove these comments before deploying, json doesn't like comments)
          },
          "Action" : "kms:*",
          "Resource" : "*"
        },
        {
          "Sid" : "SpokeBuilderAccess",
          "Effect" : "Allow",
          "Action" : [
            "kms:Decrypt",
            "kms:DescribeKey"
          ],
          "Resource" : "*",
          "Principal" : {
            "AWS" : [
              "arn:aws:iam::bbbbbbbbb:role/SpokeABuilderExecutionRole"
            ]
          }
        }
      ]
    }
  )
  tags = {
    Terraform = "true"
  }
}
