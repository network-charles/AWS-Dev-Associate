# create a zip file from the lambda source code
data "archive_file" "lambda" {
  source_file = "${path.module}/index.py"
  output_path = "${path.module}/index.zip"
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
data "aws_iam_policy" "AmazonDynamoDBFullAccess" {
  name = "AmazonDynamoDBFullAccess"
}

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  name = "AWSLambdaBasicExecutionRole"
}
