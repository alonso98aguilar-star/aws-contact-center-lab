data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name                 = "contact-center-lambda-role"
  description          = "Rol de ejecucion para el Lambda que procesa contactos de Amazon Connect"
  assume_role_policy    = data.aws_iam_policy_document.lambda_assume_role.json
  force_detach_policies = true
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "dynamodb_write" {
  statement {
    effect    = "Allow"
    actions   = ["dynamodb:PutItem"]
    resources = [aws_dynamodb_table.contact_records.arn]
  }
}

resource "aws_iam_role_policy" "dynamodb_write" {
  name   = "ContactRecordsWriteAccess"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.dynamodb_write.json
}
