import json
import boto3
from botocore.exceptions import ClientError

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='us-west-1')
table = dynamodb.Table('resume-visitors-tf')

def lambda_handler(event, context):
    print(f"=== DEBUG INFO ===")
    print(f"Event: {json.dumps(event, indent=2)}")
    print(f"Headers: {event.get('headers', {})}")
    
    # TEMPORARY: Allow all origins for debugging
    headers = event.get('headers', {})
    cors_origin = headers.get('origin') or headers.get('Origin') or '*'
    print(f"Using CORS origin: {cors_origin}")
    
    try:
        # Get the HTTP method
        http_method = event.get('httpMethod', 'GET')
        print(f"HTTP Method: {http_method}")
        
        # Handle preflight OPTIONS request
        if http_method == 'OPTIONS':
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',  # Allow all for testing
                    'Access-Control-Allow-Methods': 'POST, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
                    'Access-Control-Max-Age': '86400'
                },
                'body': ''
            }
        
        # Handle POST request - increment counter and return current count
        elif http_method == 'POST':
            print("Processing POST request...")
            
            # Increment the visitor count atomically
            response = table.update_item(
                Key={'id': 'visitors'},
                UpdateExpression='ADD #vc :inc',
                ExpressionAttributeNames={
                    '#vc': 'visitor-count'
                },
                ExpressionAttributeValues={
                    ':inc': 1
                },
                ReturnValues='UPDATED_NEW'
            )
            
            print(f"DynamoDB response: {response}")
            
            # Get the updated count
            visitor_count = response['Attributes']['visitor-count']
            
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',  # Allow all for testing
                    'Access-Control-Allow-Methods': 'POST, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({
                    'visitor_count': int(visitor_count),
                    'message': 'Counter incremented successfully'
                })
            }
        
        # Handle unsupported HTTP methods
        else:
            print(f"Unsupported method: {http_method}")
            return {
                'statusCode': 405,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({'error': f'Method {http_method} not allowed'})
            }
            
    except ClientError as e:
        print(f"DynamoDB ClientError: {e}")
        
        # Handle case where item doesn't exist - create it
        if e.response['Error']['Code'] == 'ValidationException':
            try:
                print("Creating initial counter item...")
                # Create the item with initial count of 1
                table.put_item(
                    Item={
                        'id': 'visitors',
                        'visitor-count': 1
                    }
                )
                
                return {
                    'statusCode': 200,
                    'headers': {
                        'Access-Control-Allow-Origin': '*',
                        'Content-Type': 'application/json'
                    },
                    'body': json.dumps({
                        'visitor_count': 1,
                        'message': 'Counter initialized'
                    })
                }
            except Exception as create_error:
                print(f"Error creating counter: {create_error}")
                return {
                    'statusCode': 500,
                    'headers': {
                        'Access-Control-Allow-Origin': '*',
                        'Content-Type': 'application/json'
                    },
                    'body': json.dumps({'error': f'Failed to create counter: {str(create_error)}'})
                }
        else:
            print(f"Other DynamoDB error: {e}")
            return {
                'statusCode': 500,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Content-Type': 'application/json'
                },
                'body': json.dumps({'error': f'DynamoDB error: {str(e)}'})
            }
            
    except Exception as e:
        print(f"Unexpected error: {e}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': f'Unexpected error: {str(e)}'})
        }