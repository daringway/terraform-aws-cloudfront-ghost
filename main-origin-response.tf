data aws_iam_policy_document assume_role_policy {
  version = "2012-10-17"
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource aws_iam_role lambda {
  name               = "${local.lambda_name}-${data.aws_region.current.name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  tags               = local.tags
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data archive_file lambdazip {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source_dir  = "${path.module}/lambda"
}

resource aws_lambda_function origin_response {
  function_name = local.lambda_name
  role          = aws_iam_role.lambda.arn
  publish       = true
  runtime       = "nodejs20.x"
  handler       = "origin_response.handler"
  tags          = local.tags
  memory_size   = 128
  timeout       = 5

  filename         = data.archive_file.lambdazip.output_path
  source_code_hash = data.archive_file.lambdazip.output_base64sha256
}
