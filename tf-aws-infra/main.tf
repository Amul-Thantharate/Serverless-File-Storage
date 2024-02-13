#define variables
locals {
  lambda_src_dir    = "${path.module}/../back-end/"
  lambda_function_zip_path = "${path.module}/lambda/lambda_function.zip"
}

# Create S3 buckets for uploading user content from API Gateway Endpoint
resource "aws_s3_bucket" "user_content_bucket" {
  bucket = var.user_bucket
  force_destroy = true
}

resource "aws_s3_bucket_ownership_controls" "user_content_bucket" {
  bucket = aws_s3_bucket.user_content_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "user_content_bucket" {
  depends_on = [aws_s3_bucket_ownership_controls.user_content_bucket]

  bucket = aws_s3_bucket.user_content_bucket.id
  acl    = "private"
}

# Create an IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "LambdaRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Create S3 policy for Lambda functiion role to get and put objects to S3 bucket
data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:CopyObject", "s3:HeadObject",
                    "logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "policy" {
  name        = "lambda-policy"
  policy      = data.aws_iam_policy_document.policy.json
}

# Attach the AWSLambdaBasicExecutionRole policy to the IAM role
resource "aws_iam_role_policy_attachment" "lambda_role_policy" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.lambda_role.name
}

# Create the Lambda function using data resource
data "archive_file" "lambda" {
  source_dir  = local.lambda_src_dir
  output_path = local.lambda_function_zip_path
  type        = "zip"
}
resource "aws_lambda_function" "file_uploader_lambda" {
  filename      = local.lambda_function_zip_path 
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = var.lambda_runtime
  timeout       = 20
  memory_size   = 128
  source_code_hash = data.archive_file.lambda.output_base64sha256

  environment {
    variables = {
      USER_BUCKET = var.user_bucket,
    }
  }

}

# Create API Gateway

resource "aws_api_gateway_rest_api" "FileUploderService" {
  name = "FileUploderService"
}

resource "aws_api_gateway_resource" "FileUploderService" {
  parent_id   = aws_api_gateway_rest_api.FileUploderService.root_resource_id
  path_part   = "upload"
  rest_api_id = aws_api_gateway_rest_api.FileUploderService.id
}

resource "aws_api_gateway_method" "FileUploderService" {
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.FileUploderService.id
  rest_api_id   = aws_api_gateway_rest_api.FileUploderService.id
}

resource "aws_api_gateway_integration" "FileUploderService" {
  http_method = aws_api_gateway_method.FileUploderService.http_method
  resource_id = aws_api_gateway_resource.FileUploderService.id
  rest_api_id = aws_api_gateway_rest_api.FileUploderService.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.file_uploader_lambda.invoke_arn
}

# Enabling CORS

resource "aws_api_gateway_method_response" "FileUploderService" {
  rest_api_id = aws_api_gateway_rest_api.FileUploderService.id
  resource_id = aws_api_gateway_resource.FileUploderService.id
  http_method = aws_api_gateway_method.FileUploderService.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true
  }

}

resource "aws_api_gateway_deployment" "FileUploderService" {
  rest_api_id = aws_api_gateway_rest_api.FileUploderService.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.FileUploderService.id,
      aws_api_gateway_method.FileUploderService.id,
      aws_api_gateway_integration.FileUploderService.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.FileUploderService.id
  rest_api_id   = aws_api_gateway_rest_api.FileUploderService.id
  stage_name    = "prod"
}

# Permission for API Gateway to invoke lambda function
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.file_uploader_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.aws_region}:${var.aws_account_id}:${aws_api_gateway_rest_api.FileUploderService.id}/*/${aws_api_gateway_method.FileUploderService.http_method}${aws_api_gateway_resource.FileUploderService.path}"
}


# Creating S3 bucket and cloudFront Distribution for the web app - (front-end)

resource "aws_s3_bucket" "file_uploader_app_bucket" {
  bucket = var.webapp_bucket
  force_destroy = true

  tags = {
    Name = "File Uploader Service App Bucket"
  }
}

resource "aws_s3_bucket_ownership_controls" "file_uploader_app_bucket_owner" {
  bucket = aws_s3_bucket.file_uploader_app_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "file_uploader_app_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.file_uploader_app_bucket_owner]
  bucket = aws_s3_bucket.file_uploader_app_bucket.id
  acl    = "private"
}



