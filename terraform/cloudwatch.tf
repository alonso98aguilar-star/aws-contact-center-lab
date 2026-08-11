resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/contact-center-processor"
  retention_in_days = 14
}

resource "aws_cloudwatch_log_metric_filter" "error_count" {
  name           = "ErrorCount"
  log_group_name = aws_cloudwatch_log_group.lambda_logs.name
  pattern         = "ERROR"

  metric_transformation {
    name          = "LambdaErrors"
    namespace     = "ContactCenterLab"
    value         = "1"
    default_value = "0"
  }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "contact-center-lambda-errors"
  alarm_description   = "Se dispara si el Lambda del contact center registra errores"
  namespace           = "ContactCenterLab"
  metric_name         = "LambdaErrors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
}
