# Scale up weekdays at beginning of day
resource "aws_appautoscaling_scheduled_action" "ADOBuilderWeekdayScaleUp" {
  count              = var.enable_scaling ? 1 : 0
  name               = "ADOBuilderScaleUp"
  service_namespace  = aws_appautoscaling_target.AzureDevOpsBuilderServiceAutoScalingTarget[0].service_namespace
  resource_id        = aws_appautoscaling_target.AzureDevOpsBuilderServiceAutoScalingTarget[0].resource_id
  scalable_dimension = aws_appautoscaling_target.AzureDevOpsBuilderServiceAutoScalingTarget[0].scalable_dimension
  schedule           = "cron(0 6 ? * MON-FRI *)" #Every weekday at 6 a.m.
  timezone           = "America/Los_Angeles"

  scalable_target_action {
    min_capacity = var.autoscale_task_weekday_scale_up
    max_capacity = var.autoscale_task_weekday_scale_up
  }
}

# Scale down weekdays at end of day
resource "aws_appautoscaling_scheduled_action" "ADOBuilderWeekdayScaleDown" {
  count              = var.enable_scaling ? 1 : 0
  name               = "ADOBuilderScaleDown"
  service_namespace  = aws_appautoscaling_target.AzureDevOpsBuilderServiceAutoScalingTarget[0].service_namespace
  resource_id        = aws_appautoscaling_target.AzureDevOpsBuilderServiceAutoScalingTarget[0].resource_id
  scalable_dimension = aws_appautoscaling_target.AzureDevOpsBuilderServiceAutoScalingTarget[0].scalable_dimension
  schedule           = "cron(0 20 ? * MON-FRI *)" #Every weekday at 8 p.m.
  timezone           = "America/Los_Angeles"

  scalable_target_action {
    min_capacity = var.autoscale_task_weekday_scale_down
    max_capacity = var.autoscale_task_weekday_scale_down
  }
}

# Scale to 0 to refresh fleet
resource "aws_appautoscaling_scheduled_action" "ADOBuilderRefresh" {
  count              = var.enable_scaling ? 1 : 0
  name               = "ADOBuilderRefresh"
  service_namespace  = aws_appautoscaling_target.AzureDevOpsBuilderServiceAutoScalingTarget[0].service_namespace
  resource_id        = aws_appautoscaling_target.AzureDevOpsBuilderServiceAutoScalingTarget[0].resource_id
  scalable_dimension = aws_appautoscaling_target.AzureDevOpsBuilderServiceAutoScalingTarget[0].scalable_dimension
  schedule           = "cron(0 0 ? * MON-FRI *)" #Every weekday at midnight
  timezone           = "America/Los_Angeles"

  scalable_target_action {
    min_capacity = 0
    max_capacity = 0
  }
}
