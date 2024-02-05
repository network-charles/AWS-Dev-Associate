# output the HTTP API v2 gateway invocation url 
output "api_url" {
  value = "${aws_apigatewayv2_api.http-crud-tutorial-api.api_endpoint}/items"
}
