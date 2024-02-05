# IAM Role for Lambda to acces API gateway and Cloudwatch 
resource "aws_iam_role" "http-crud-tutorial-role" {
  name               = "http-crud-tutorial-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

# attach the policies to the role 
resource "aws_iam_role_policy_attachment" "AmazonDynamoDBFullAccess" {
  role       = aws_iam_role.http-crud-tutorial-role.id
  policy_arn = data.aws_iam_policy.AmazonDynamoDBFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaBasicExecutionRole" {
  role       = aws_iam_role.http-crud-tutorial-role.id
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}


# define a cloudwatch log group for lamba
resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.http-crud-tutorial-function.function_name}"
  lifecycle {
    prevent_destroy = false
  }
}

# define a cognito pool
resource "aws_cognito_user_pool" "api" {
  name = "api"
  password_policy {
    minimum_length    = 6
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

# add a user to the pool 
resource "aws_cognito_user" "charles" {
  user_pool_id = aws_cognito_user_pool.api.id
  username     = var.username
  password     = var.password
}

# define a client that interacts with API gateway 
resource "aws_cognito_user_pool_client" "api" {
  name         = "api"
  user_pool_id = aws_cognito_user_pool.api.id
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_CUSTOM_AUTH"
  ]
  supported_identity_providers = ["COGNITO"]
}

# generate the client id token and save it into a .txt file
resource "null_resource" "generate_client_id_token" {

  triggers = {
    username  = var.username
    password  = var.password
    client_id = aws_cognito_user_pool_client.api.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws cognito-idp initiate-auth \
        --client-id ${self.triggers.client_id} \
        --auth-flow USER_PASSWORD_AUTH \
        --auth-parameters USERNAME=${self.triggers.username},PASSWORD=${self.triggers.password} \
        --region eu-west-2 > client_id_token.txt
    EOT
  }
}
