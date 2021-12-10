resource "aws_ecs_service" "azure_devops_builder_service" {
  name             = "AzureDevOpsBuilderService"
  cluster          = aws_ecs_cluster.fargate_cluster.id
  task_definition  = aws_ecs_task_definition.azure_devops_builder_task.arn
  desired_count    = var.autoscale_task_weekday_scale_down # Defaults to 1 instance of the task
  launch_type      = "FARGATE"
  platform_version = "LATEST"
  network_configuration {
    subnets         = var.service_subnets # List of subnets for where service should launch tasks in
    security_groups = var.service_sg # List of security groups to provide to tasks launched within service
  }
  lifecycle {
    ignore_changes = [desired_count] # Ignored desired count changes live, permitting schedulers to update this value without terraform reverting
  }
}
