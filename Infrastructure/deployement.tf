terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}
provider "aws" {
  region = "ap-south-1"
}

# IAM roles
resource "aws_iam_role" "lambda_post_role" {
  name = "lambda-post-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_get_role" {
  name = "lambda-get-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Attach policies to IAM lambda_post_role
resource "aws_iam_role_policy_attachment" "post_lambda_dynamo_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  role       = aws_iam_role.lambda_post_role.name
}

resource "aws_iam_role_policy_attachment" "post_lambda_sqs_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  role       = aws_iam_role.lambda_post_role.name
}

resource "aws_iam_role_policy_attachment" "post_lambda_full_access_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  role       = aws_iam_role.lambda_post_role.name
}

resource "aws_iam_role_policy_attachment" "post_lambda_basic_execution_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_post_role.name
}

resource "aws_iam_role_policy_attachment" "post_cloud_watch_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
  role       = aws_iam_role.lambda_post_role.name
}


# Attach policies to IAM lambda_get_role
resource "aws_iam_role_policy_attachment" "get_lambda_sqs_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
  role       = aws_iam_role.lambda_get_role.name
}

resource "aws_iam_role_policy_attachment" "get_lambda_full_access_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  role       = aws_iam_role.lambda_get_role.name
}

resource "aws_iam_role_policy_attachment" "get_lambda_basic_execution_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_get_role.name
}

resource "aws_iam_role_policy_attachment" "get_cloud_watch_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
  role       = aws_iam_role.lambda_get_role.name
}

resource "aws_iam_role_policy_attachment" "get_secrets_manager_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
  role       = aws_iam_role.lambda_get_role.name
}


# Lambda functions
resource "aws_lambda_function" "process_order_lambda" {
  function_name = "ProcessOrder"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_post_role.arn
  filename      = "../Lambdas/ProcessOrder/lambda_function.zip"
}


resource "aws_lambda_function" "get_customer_orders_lambda" {
  function_name = "GetCustomerOrders"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_get_role.arn
  filename      = "../Lambdas/GetCustomerOrders/lambda_function.zip"
}

resource "aws_lambda_function" "create_order_lambda" {
  function_name = "CreateOrder"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_post_role.arn
  filename      = "../Lambdas/CreateOrder/lambda_function.zip"
}

resource "aws_lambda_function" "update_stock_lambda" {
  function_name = "UpdateStock"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_post_role.arn
  filename      = "../Lambdas/UpdateStock/lambda_function.zip"
}

# SQS Queues, DynamoDB tables, API Gateway, and other resources...

resource "aws_lambda_permission" "post_api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_order_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

resource "aws_lambda_permission" "get_api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_customer_orders_lambda.function_name
  principal     = "apigateway.amazonaws.com"
}

# SQS Queues
resource "aws_sqs_queue" "process_queue" {
  name = "process_queue"
}

resource "aws_sqs_queue" "stock_queue" {
  name = "stock_queue"
}

# Lambda triggers
resource "aws_lambda_event_source_mapping" "process_order_trigger" {
  event_source_arn = aws_sqs_queue.process_queue.arn
  function_name   = aws_lambda_function.process_order_lambda.arn
}

resource "aws_lambda_event_source_mapping" "update_stock_trigger" {
  event_source_arn = aws_sqs_queue.stock_queue.arn
  function_name   = aws_lambda_function.update_stock_lambda.arn
}

# DynamoDB tables
resource "aws_dynamodb_table" "customer_order_table" {
  name           = "CustomerOrders"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "order_id"
  attribute {
    name = "order_id"
    type = "N"
  }
}

resource "aws_dynamodb_table" "product_info_table" {
  name           = "ProductsInfo"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "product_id"
  attribute {
    name = "product_id"
    type = "N"
  }
}

# API Gateway
resource "aws_api_gateway_rest_api" "my_api" {
  name        = "MyAPI"
  description = "My API Gateway"
}

resource "aws_api_gateway_resource" "order_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = "order"
}

resource "aws_api_gateway_method" "get_customer_orders_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.order_resource.id
  http_method   = "GET"

  authorization = "NONE"
}

resource "aws_api_gateway_method" "create_order_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.order_resource.id
  http_method   = "POST"

  authorization = "NONE"
}


resource "aws_api_gateway_integration" "get_customer_orders_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.order_resource.id
  http_method = aws_api_gateway_method.get_customer_orders_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.get_customer_orders_lambda.invoke_arn
}

resource "aws_api_gateway_integration" "create_order_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.order_resource.id
  http_method = aws_api_gateway_method.create_order_method.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.create_order_lambda.invoke_arn
}


# Deploy the API
resource "aws_api_gateway_deployment" "my_api_deployment" {
  depends_on       = [aws_api_gateway_integration.get_customer_orders_integration, aws_api_gateway_integration.create_order_integration]
  rest_api_id      = aws_api_gateway_rest_api.my_api.id
  stage_name       = "prod"  # You can change this to your desired stage name
  description      = "Production Deployment"
  variables        = {}  # Optional. You can define stage variables here.
}

# Create the stage
resource "aws_api_gateway_stage" "my_api_stage" {
  stage_name      = aws_api_gateway_deployment.my_api_deployment.stage_name
  rest_api_id     = aws_api_gateway_deployment.my_api_deployment.rest_api_id
  deployment_id   = aws_api_gateway_deployment.my_api_deployment.id

  # Additional stage configurations, if needed
}

# Create Secrets Manager Secret
resource "aws_secretsmanager_secret" "dynamo_secret" {
  name = "prod/dynamo"
}

variable "access_key" {
  default = os.getenv("AWS_ACCESS_KEY_ID")
}

variable "secret_key" {
  default = os.getenv("AWS_SECRET_ACCESS_KEY")
}

resource "aws_secretsmanager_secret_version" "dynamo_secret_version" {
  secret_id = aws_secretsmanager_secret.dynamo_secret.id
  secret_string = jsonencode({
    "access_key" = var.access_key,
    "secret_key" = var.secret_key
  })
}
