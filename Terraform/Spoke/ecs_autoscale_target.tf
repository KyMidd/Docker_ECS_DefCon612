resource "aws_appautoscaling_target" "AzureDevOpsBuilderServiceAutoScalingTarget" {
  count              = var.enable_scaling ? 1 : 0
  min_capacity       = var.autoscale_task_weekday_scale_down
  max_capacity       = var.autoscale_task_weekday_scale_up
  resource_id        = "service/${aws_ecs_cluster.fargate_cluster.name}/${aws_ecs_service.azure_devops_builder_service.name}" # service/(clusterName)/(serviceName)
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  lifecycle {
    ignore_changes = [
      min_capacity,
      max_capacity,
    ]
  }
}