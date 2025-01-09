# Create CloudWatch metric filter for Lambda log group
resource "aws_cloudwatch_log_metric_filter" "lambda_metric_filter" {
  name           = "info-count"
  pattern        = "[INFO]"
  log_group_name = aws_cloudwatch_log_group.lambda_log_group.name

  metric_transformation {
    name      = "info-count"
    namespace = "/moviedb-api/yap"
    value     = "1"
  }
}

# Create CloudWatch alarm
resource "aws_cloudwatch_metric_alarm" "info_count_alarm" {
  alarm_name                = "yap-info-count-breach"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = 2
  metric_name               = "info-count"
  namespace                 = "/moviedb-api/yap"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 10
  #alarm_actions             = [aws_sns_topic.sns.arn]
  #alarm_description         = "This metric monitors ec2 cpu utilization"
  #insufficient_data_actions = []
}