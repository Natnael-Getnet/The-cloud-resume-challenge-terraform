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
