import boto3
import json
from botocore.exceptions import ClientError

print('Loading function')

# Use resource instead of client for easier operations
dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table('resume-visitor-count')  # Replace with your table name

def lambda_handler(event, context):
    """
    Simple visitor counter that increments count in DynamoDB
    and returns the current count
    """
    
    try:
        # Update the visitor count (increment by 1)
        response = table.update_item(
            Key={
                'id': 'visitors'  # This is your partition key value
            },
            UpdateExpression='ADD visitor_count :val',
            ExpressionAttributeValues={
                ':val': 1
            },
            ReturnValues='UPDATED_NEW'
        )
        
        # Get the updated count
        visitor_count = int(response['Attributes']['visitor_count'])
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',  # Replace * with your domain for security
                'Access-Control-Allow-Methods': 'GET',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({
                'count': visitor_count
            })
        }
        
    except ClientError as e:
        print(f"Error: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
            },
            'body': json.dumps({
                'error': 'Could not update visitor count',
                'message': str(e)
            })
        }
    except Exception as e:
        print(f"Unexpected error: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }