# Create an IAM role for the EC2 instance to allow AWS SSM access.
resource "aws_iam_role" "read-object-role" {
  name               = "read-object-role-Role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json

  tags = {
    "Name" = "read-object-role"
  }
}

resource "aws_iam_role_policy_attachment" "AmazonS3ReadOnlyAccess" {
  role       = aws_iam_role.read-object-role.id
  policy_arn = data.aws_iam_policy.AmazonS3ReadOnlyAccess.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.read-object-role.id
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy_attachment" "AWSXrayWriteOnlyAccess" {
  role       = aws_iam_role.read-object-role.id
  policy_arn = data.aws_iam_policy.AWSXrayWriteOnlyAccess.arn
}

# Create cloudwatch log group
resource "aws_cloudwatch_log_group" "read-object-function" {
  name              = "/aws/lambda/read-object-function"
  retention_in_days = 1
}

# Create an x-ray rule 
resource "aws_xray_sampling_rule" "s3" {
  rule_name      = "s3"
  priority       = 9999
  version        = 1
  reservoir_size = 1
  fixed_rate     = 0.05
  url_path       = "*"
  host           = "*"
  http_method    = "*"
  service_type   = "*"
  service_name   = "*"
  resource_arn   = "*"

  tags = {
    "name" = "s3"
  }
}
