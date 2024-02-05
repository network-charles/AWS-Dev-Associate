import json
from decimal import Decimal
import boto3
from botocore.exceptions import ClientError

class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, Decimal):
            return str(o)
        return super(DecimalEncoder, self).default(o)

dynamodb = boto3.resource('dynamodb')
table_name = 'http-crud-tutorial-items'
table = dynamodb.Table(table_name)

def handler(event, context):
    body = None
    status_code = 200
    headers = {
        'Content-Type': 'application/json',
    }

    try:
        # Based on API Gateway Payload v2.0
        if event['routeKey'] == 'PUT /items':
            request_json = json.loads(event['body'])
            put = table.put_item(
                    Item=request_json
                )
            body = f"Put item with id: {request_json['id']}"

        # Get all items 
        elif event['routeKey'] == 'GET /items':
            scan = table.scan()
            items = scan.get('Items', [])
            body = items

        # Get an item based on the path parameter
        elif event['routeKey'] == 'GET /items/{id}':
            path_parameters = event['pathParameters']
            id_value = path_parameters['id']
            get = table.get_item(
                        Key={
                            'id': id_value}
                        )
            body = get.get('Item', None)

        # Delete an item based on the path parameter    
        elif event['routeKey'] == 'DELETE /items/{id}':
            path_parameters = event['pathParameters']
            id_value = path_parameters['id']
            delete = table.delete_item(
                Key={
                    'id': id_value}
                )
            body = f"Deleted item with id: {id_value}"

        else:   
            raise Exception(f"Unsupported route: {event['routeKey']}")
    except ClientError as e:
        status_code = 400
        body = str(e)
    finally:
        body = json.dumps(body, cls=DecimalEncoder)

    return {
        'statusCode': status_code,
        'body': body,
        'headers': headers,
    }
