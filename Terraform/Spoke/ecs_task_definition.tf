resource "aws_ecs_task_definition" "azure_devops_builder_task" {
  family                   = "AzureDevOpsBuilder"
  execution_role_arn       = aws_iam_role.SpokeABuilderExecutionRole.arn
  #task_role_arn            = xxxxxx # Optional, ARN of IAM role assigned to container once booting, grants rights
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  # Fargate cpu/mem must match available options: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu    = var.fargate_cpu # Variable, default to 1024
  memory = var.fargate_mem # Variable, defaults to 2048
  container_definitions = jsonencode(
    [
      {
        name      = "AzureDevOpsBuilder"
        image     = "${var.image_ecr_url}:${var.image_tag}" # The URL of the Hub's ECR and a tag, e.g. aaaaaaa.dkr.ecr.us-east-1.amazonaws.com/hub_ecr_repository:prod
        cpu       = "${var.container_cpu}" # Variable, default to 1024
        memory    = "${var.container_mem}" # Variable, defaults to 2048
        essential = true
        environment : [
          { name : "AZP_URL", value : "https://dev.azure.com/foobar" },
          { name : "AZP_POOL", value : "BuilderPoolName" } # Optional, builder will join "default" pool if not provided
        ]
        secrets : [
          { name : "AZP_TOKEN", valueFrom : "${var.ado_join_secret_token_arn}" } # ARN of Hub's secret to fetch and inject
        ]
        logConfiguration : {
          logDriver : "awslogs",
          options : {
            awslogs-group : "AzureDevOpsBuilderLogGroup",
            awslogs-region : "${data.aws_region.current_region.name}", # Data source to gather region, e.g. data "aws_region" "current_region" {}
            awslogs-stream-prefix : "AzureDevOpsBuilder"
          }
        }
      }
    ]
  )

  tags = {
    Name = "AzureDevOpsBuilder"
  }
}