from unittest.mock import patch
from botocore.exceptions import ClientError
import lambda_function

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

# Test for no origin received
def test_no_origin_header():
    # Arrange: Event with no origin:
    event = {

    }

    # Action: call function
    result = lambda_function.lambda_handler(event, None)

    # Assertion: Check result
    assert result['statusCode'] == 403 
    # assert 'error' in result['body'] == 'No origin header - access denied' - This was my attempt, incorrect syntax
    assert 'No origin header - access denied' in result['body']

# Test for origin not allowed 
def test_origin_not_allowed():
    # Arrange: Event with origin not allowed
    event = {
        'headers': {
            'Origin': 'https://domain-notallowed.com',
            'Content-Type': 'application/json'
        }
    }

    # Action: Call function
    result = lambda_function.lambda_handler(event, None)

    # Assertion: Check result
    assert result['statusCode'] == 403
    assert 'Origin not allowed' in result['body']

# Test for valid origin with options request
def test_origin_options():
    # Arrange: Event with Valid Origin, Options Request
    event = {
        'httpMethod': 'OPTIONS',
        'headers': {
            'Origin': 'https://resume.csruiz.com', 
        }
    }

    # Action: Call function
    result = lambda_function.lambda_handler(event, None)

    # Assertion: Check result
    assert result['statusCode'] == 200
    assert 'OPTIONS' in result['headers']['Access-Control-Allow-Methods']

# Test for Valid origin with post request and successful DB update
def test_origin_post_db_update():
    # Arrange: Event with valid origin, post and DB update
    with patch('lambda_function.table') as mock_table:
        # Mock the update_item response to include the expected return value
        mock_table.update_item.return_value = {
            'Attributes': {'visitor-count': 5},
        }

        event = {
            'httpMethod': 'POST',
            'headers': {'Origin': 'https://resume.csruiz.com'},
        }

        # Action: Call function
        result = lambda_function.lambda_handler(event, None)

        # Assertion: Check results
        assert result['statusCode'] == 200
        assert 'POST' in result['headers']['Access-Control-Allow-Methods']
        
        # Verify that update_item was called with the correct parameters
        mock_table.update_item.assert_called_once_with(
            Key={'id': 'visitors'},
            UpdateExpression='ADD #vc :inc',
            ExpressionAttributeNames={'#vc': 'visitor-count'},
            ExpressionAttributeValues={':inc': 1},
            ReturnValues='UPDATED_NEW'
        )
# Test for database error
def test_ddb_error():
    # Arrange: Event with DDB error
    with patch('lambda_function.table') as mock_table:
        # Mock DDB error
        mock_table.update_item.side_effect = ClientError(
            error_response={
                'Error': {
                    'Code': 'InternalServerError',
                    'Message': 'An error occured (InternalServerError) when calling the UpdateItem operation: Internal server error'
                }
            },
            operation_name='UpdateItem'
        )

        event = {
            'httpMethod':'POST',
            'headers': {'Origin': 'https://resume.csruiz.com'}
        }

        # Action: Call function
        result = lambda_function.lambda_handler(event,None)

        # Assertion: Check results
        assert result['statusCode'] == 500
        assert 'InternalServerError' in result['body']

        mock_table.update_item.assert_called_once()

# Test for unsupported http method
def test_unsupported_http_method():
    # Arrange: Event with unsupported http method
    event = {
        'httpMethod': 'GET',
        'headers':{'Origin': 'https://resume.csruiz.com'}
    }

    # Action: Call function
    result = lambda_function.lambda_handler(event,None)

    # Assertion: Check results
    assert result['statusCode'] == 405
    assert 'Method not allowed' in result['body']
