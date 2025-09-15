import json
import boto3
from botocore.exceptions import ClientError

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb', region_name='us-west-1')
table = dynamodb.Table('resume-visitors-tf')

def lambda_handler(event, context):
    # Allowed origins
    allowed_origins = [
        'https://resume.csruiz.com',
        'https://d1rkalisahkhhn.cloudfront.net' #OLD: 'https://d237sr1p0h65er.cloudfront.net'
    ]
    
    # Get the origin from headers
    headers = event.get('headers', {})
    cors_origin = headers.get('origin') or headers.get('Origin')
    
    if not cors_origin:
        # No origin header (direct API calls, testing) - block or allow based on your preference
        # For testing purposes, you might want to allow, but for production, consider blocking
        return {
            'statusCode': 403,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'No origin header - access denied'})
        }
    elif cors_origin not in allowed_origins:
        # Block requests from unauthorized origins
        return {
            'statusCode': 403,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'Origin not allowed'})
        }
    else:
        # Get the HTTP method
        http_method = event.get('httpMethod', 'GET')
        
        # Handle preflight OPTIONS request
        if http_method == 'OPTIONS':
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': cors_origin,
                    'Access-Control-Allow-Methods': 'POST, OPTIONS',
                    'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
                    'Access-Control-Max-Age': '86400'
                },
                'body': ''
            }
        
        # Handle POST request - increment counter and return current count
        elif http_method == 'POST':
            try:
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
                
                # Get the updated count
                visitor_count = response['Attributes']['visitor-count']
                
                return {
                    'statusCode': 200,
                    'headers': {
                        'Access-Control-Allow-Origin': cors_origin,
                        'Access-Control-Allow-Methods': 'POST, OPTIONS',
                        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
                        'Content-Type': 'application/json'
                    },
                    'body': json.dumps({
                        'visitor_count': int(visitor_count),
                        'message': 'Counter incremented successfully'
                    })
                }
                
            except ClientError as e:
                # Handle case where item doesn't exist - create it
                if e.response['Error']['Code'] == 'ValidationException':
                    try:
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
                                'Access-Control-Allow-Origin': cors_origin,
                                'Content-Type': 'application/json'
                            },
                            'body': json.dumps({
                                'visitor_count': 1,
                                'message': 'Counter initialized'
                            })
                        }
                    except Exception as create_error:
                        return {
                            'statusCode': 500,
                            'headers': {
                                'Access-Control-Allow-Origin': cors_origin,
                                'Content-Type': 'application/json'
                            },
                            'body': json.dumps({'error': f'Failed to create counter: {str(create_error)}'})
                        }
                else:
                    return {
                        'statusCode': 500,
                        'headers': {
                            'Access-Control-Allow-Origin': cors_origin,
                            'Content-Type': 'application/json'
                        },
                        'body': json.dumps({'error': f'DynamoDB error: {str(e)}'})
                    }
            except Exception as e:
                return {
                    'statusCode': 500,
                    'headers': {
                        'Access-Control-Allow-Origin': cors_origin,
                        'Content-Type': 'application/json'
                    },
                    'body': json.dumps({'error': f'Unexpected error: {str(e)}'})
                }
        
        # Handle unsupported HTTP methods - show what was received
        return {
            'statusCode': 405,
            'headers': {
                'Access-Control-Allow-Origin': cors_origin,
                'Content-Type': 'application/json'
            },
            'body': json.dumps({'error': 'Method not allowed'})
        }