data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/contact_processor.py"
  output_path = "${path.module}/build/function.zip"
}

resource "aws_lambda_function" "contact_processor" {
  function_name    = "contact-center-processor"
  runtime          = "python3.13"
  handler          = "contact_processor.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  timeout          = 10
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  depends_on = [aws_cloudwatch_log_group.lambda_logs]
}
