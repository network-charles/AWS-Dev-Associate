# Create a bucket
resource "aws_s3_bucket" "bucket" {
  bucket = "test-bucket-charles-uneze"

  tags = {
    "Name" = "bucket"
  }
}
/*
# Upload an object that will invoke lambda when an action occurs
resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "event.txt"
  source = "./event.txt"

  depends_on = [
    aws_lambda_permission.s3-invoke-lambda,
    aws_s3_bucket_notification.bucket_notification,
    aws_xray_sampling_rule.s3
  ]
}
*/

# Create a lambda function
resource "aws_lambda_function" "read-object-function" {
  filename      = data.archive_file.lambda.output_path
  function_name = "read-object-function"
  role          = aws_iam_role.read-object-role.arn
  handler       = "put_object.lambda_handler"
  runtime       = "python3.11"

  tracing_config {
    mode = "Active"
  }

  logging_config {
    log_group  = aws_cloudwatch_log_group.read-object-function.id
    log_format = "JSON"
  }
}

# Add s3 trigger 
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.read-object-function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "event.txt"
  }
}

# Enable s3 to invoke the lambda function
resource "aws_lambda_permission" "s3-invoke-lambda" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.read-object-function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}
