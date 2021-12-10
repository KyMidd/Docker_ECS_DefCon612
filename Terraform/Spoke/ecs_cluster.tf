resource "aws_ecs_cluster" "fargate_cluster" {
  name = "AzureDevOpsBuilderCluster"
  capacity_providers = [
    "FARGATE"
  ]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
}