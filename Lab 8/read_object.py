import boto3
import json

def lambda_handler(event, context):
    s3_event = event['Records'][0]['s3']
    bucket_name = s3_event['bucket']['name']
    file_key = s3_event['object']['key']

    s3_client = boto3.client('s3')
    
    try:
        response = s3_client.get_object(Bucket=bucket_name, Key=file_key)
        content = response['Body'].read().decode('utf-8')
        
        print("Output: " + content)
        
    except Exception as e:
        print("Exception: {}".format(e))

    print("Finished... processing file")
    return "Ok"
