resource "aws_iam_role" "role_lambda" {
  name = var.role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"

      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "lambda_polices" {
  name = var.policy
  role = aws_iam_role.role_lambda
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "*"
    }]
  })
}

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/index.py"
  output_path = "${path.module}/index.zip"
}

resource "aws_lambda_function" "python_lambda" {
  function_name    = var.lambda_name
  role             = aws_iam_role.role_lambda.arn
  runtime          = "python3.12"
  handler          = "index.handler"
  filename         = data.archive_file.lambda_function.output_path
  source_code_hash = data.archive_file.lambda_function.output_base64sha256
}


resource "aws_api_gateway_rest_api" "api_python" {
  name = "api_gateway"
}

resource "aws_api_gateway_resource" "api_resources" {
  parent_id   = aws_api_gateway_rest_api.api_python.root_resource_id
  path_part   = "hellopython"
  rest_api_id = aws_api_gateway_rest_api.api_python.id
}

resource "aws_api_gateway_method" "python_method" {
  authorization = "NONE"
  rest_api_id   = aws_api_gateway_rest_api.api_python.id
  resource_id   = aws_api_gateway_resource.api_resources.id
  http_method   = "GET"
}

resource "aws_api_gateway_integration" "python_integration" {
  integration_http_method = "POST"
  http_method             = aws_api_gateway_method.python_method.http_method
  type                    = "AWS_PROXY"
  resource_id             = aws_api_gateway_method.python_method.resource_id
  rest_api_id             = aws_api_gateway_method.python_method.rest_api_id
  uri                     = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.python_lambda.arn}/invocations"
}

resource "aws_lambda_permission" "invoke_permissions" {
  principal     = "apigateway.amazonaws.com"
  function_name = aws_lambda_function.python_lambda.function_name
  action        = "lambda:InvokeFunction"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_python.id
  depends_on  = [aws_api_gateway_method.python_method]

  triggers = {
    redeploy = timestamp()
  }
}

resource "aws_api_gateway_stage" "stage_name" {
  stage_name = "prod"
  rest_api_id = aws_api_gateway_rest_api.api_python.id
  deployment_id = aws_api_gateway_deployment.deployment.id
}


output "lambda_python" {
  value = "${aws_api_gateway_stage.stage_name.invoke_url}/${aws_api_gateway_resource.api_resources.path_part}"
}