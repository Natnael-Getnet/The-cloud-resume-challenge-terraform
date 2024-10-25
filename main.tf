terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_appautoscaling_target" "dynamodb-test-table_read_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.crc-dynamodb-table.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb-test-table_read_policy" {
  name               = "dynamodb-read-capacity-utilization-${aws_appautoscaling_target.dynamodb-test-table_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb-test-table_read_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb-test-table_read_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb-test-table_read_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_appautoscaling_target" "dynamodb-test-table_write_target" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "table/${aws_dynamodb_table.crc-dynamodb-table.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "dynamodb-test-table_write_policy" {
  name               = "dynamodb-write-capacity-utilization-${aws_appautoscaling_target.dynamodb-test-table_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb-test-table_write_target.resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb-test-table_write_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb-test-table_write_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = 70
  }
}

resource "aws_dynamodb_table_item" "crc_item" {
  table_name = aws_dynamodb_table.crc-dynamodb-table.name
  hash_key   = aws_dynamodb_table.crc-dynamodb-table.hash_key
  item       = <<ITEM
    {
        "id": {"S": "0"},
        "views": {"N": "0"}
    }
ITEM
}

resource "aws_dynamodb_table" "crc-dynamodb-table" {
  name           = "visitors-count-terraform"
  billing_mode   = "PROVISIONED"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "dev"
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "dynamodb_full_access" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.py"
  output_path = "lambda.zip"
}

resource "aws_lambda_function" "test_lambda_function" {
  function_name    = "crc-lambda"
  filename         = data.archive_file.lambda.output_path
  role             = aws_iam_role.iam_for_lambda.arn
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.12"
  handler          = "lambda.lambda_handler"
  timeout          = 10
}

resource "aws_lambda_function_url" "test_latest" {
  function_name      = aws_lambda_function.test_lambda_function.function_name
  authorization_type = "NONE"

  cors {
    allow_credentials = true
    allow_origins     = ["https://${aws_cloudfront_distribution.crc_distribution.domain_name}"]
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["date", "keep-alive"]
    expose_headers    = ["keep-alive", "date"]
    max_age           = 86400
  }
}

