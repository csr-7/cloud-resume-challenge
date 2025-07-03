import moto
import pytest
import pytest_mock

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import lambda_function

def test_intro():
    assert True

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
