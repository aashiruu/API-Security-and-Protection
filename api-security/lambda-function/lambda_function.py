```python
import json
import os

def lambda_handler(event, context):
    """Simple API handler for lab demonstration"""
    
    # Parse the HTTP method
    http_method = event.get('requestContext', {}).get('http', {}).get('method', 'GET')
    
    # Simple in-memory storage (for demo only)
    items = [
        {"id": 1, "name": "Sample Item 1", "value": 100},
        {"id": 2, "name": "Sample Item 2", "value": 200}
    ]
    
    # Handle different HTTP methods
    if http_method == 'GET':
        # Return all items
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'message': 'Items retrieved successfully',
                'items': items
            })
        }
    
    elif http_method == 'POST':
        # Add new item
        try:
            body = json.loads(event.get('body', '{}'))
            new_item = {
                'id': len(items) + 1,
                'name': body.get('name', 'Unnamed Item'),
                'value': body.get('value', 0)
            }
            items.append(new_item)
            
            return {
                'statusCode': 201,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'message': 'Item created successfully',
                    'item': new_item
                })
            }
            
        except json.JSONDecodeError:
            return {
                'statusCode': 400,
                'headers': {
                    'Content-Type': 'application/json',
                    'Access-Control-Allow-Origin': '*'
                },
                'body': json.dumps({
                    'error': 'Invalid JSON format'
                })
            }
    
    else:
        return {
            'statusCode': 405,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'error': 'Method not allowed'
            })
        }
```
