resource "aws_cloudwatch_log_group" "AzureDevOpsBuilderLogGroup" {
  name = "AzureDevOpsBuilderLogGroup"
  tags = {
    Terraform = "true"
    Name      = "AzureDevOpsBuilderLogGroup"
  }
}