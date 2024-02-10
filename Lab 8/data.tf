# create a zip file from the lambda source code
data "archive_file" "lambda" {
  source_file = "${path.module}/read_object.py"
  output_path = "${path.module}/read_object.zip"
  type        = "zip"
}

# define a service role to the assumed
data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# define policies to be attached to the role 
data "aws_iam_policy" "AmazonS3ReadOnlyAccess" {
  name = "AmazonS3ReadOnlyAccess"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy" "AWSXrayWriteOnlyAccess" {
  name = "AWSXrayWriteOnlyAccess"
}
