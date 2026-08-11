output "connect_instance_id" {
  value = aws_connect_instance.lab.id
}

output "lambda_function_arn" {
  value = aws_lambda_function.contact_processor.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.contact_records.name
}

output "cloudwatch_log_group" {
  value = aws_cloudwatch_log_group.lambda_logs.name
}
