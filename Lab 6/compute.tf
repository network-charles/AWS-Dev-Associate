# Create a dynamodb table
resource "aws_dynamodb_table" "http-crud-tutorial-items" {
  name     = "http-crud-tutorial-items"
  hash_key = "id"
  attribute {
    name = "id"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
}

# Create a lambda function
resource "aws_lambda_function" "http-crud-tutorial-function" {
  filename      = data.archive_file.lambda.output_path
  function_name = "http-crud-tutorial-function"
  role          = aws_iam_role.http-crud-tutorial-role.arn
  handler       = "index.handler"
  runtime       = "python3.11"
}

# Create alambda function url 
resource "aws_lambda_function_url" "http-crud-tutorial-function-url" {
  function_name      = aws_lambda_function.http-crud-tutorial-function.function_name
  authorization_type = "NONE"
}

# Create the api gateway
resource "aws_apigatewayv2_api" "http-crud-tutorial-api" {
  name          = "http-crud-tutorial-api"
  protocol_type = "HTTP"
  # create a default stage 
  target = aws_lambda_function_url.http-crud-tutorial-function-url.function_url

  tags = {
    "name" = "http-crud-tutorial-api"
  }
}

# Create a route to direct incoming api traffic  
resource "aws_apigatewayv2_route" "route-1" {
  api_id             = aws_apigatewayv2_api.http-crud-tutorial-api.id
  route_key          = "GET /items/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito-authorizer.id
}

resource "aws_apigatewayv2_route" "route-2" {
  api_id             = aws_apigatewayv2_api.http-crud-tutorial-api.id
  route_key          = "GET /items"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito-authorizer.id
}

resource "aws_apigatewayv2_route" "route-3" {
  api_id             = aws_apigatewayv2_api.http-crud-tutorial-api.id
  route_key          = "PUT /items"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito-authorizer.id
}

resource "aws_apigatewayv2_route" "route-4" {
  api_id             = aws_apigatewayv2_api.http-crud-tutorial-api.id
  route_key          = "DELETE /items/{id}"
  target             = "integrations/${aws_apigatewayv2_integration.lambda.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.cognito-authorizer.id
}

# Create an integration to connect a route to backend resources
resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.http-crud-tutorial-api.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.http-crud-tutorial-function.invoke_arn
  integration_method     = "POST"
  payload_format_version = "2.0"
}

# Enable api gateway to invoke the lambda function
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.http-crud-tutorial-function.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*" portion grants access from any stage, method on any resource
  # path within API Gateway.
  source_arn = "${aws_apigatewayv2_api.http-crud-tutorial-api.execution_arn}/*"
}

# define the cognito authorizer in api gateway
resource "aws_apigatewayv2_authorizer" "cognito-authorizer" {
  api_id           = aws_apigatewayv2_api.http-crud-tutorial-api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.api.id]
    issuer   = "https://${aws_cognito_user_pool.api.endpoint}"
  }
}
