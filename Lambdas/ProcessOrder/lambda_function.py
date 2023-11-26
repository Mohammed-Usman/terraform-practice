import boto3
import json
import os


def lambda_handler(event, context):
    try:

        print(event)
        order_details = event['Records'][0]['body']
        data = json.loads(order_details)

        sqs_queue_name = 'stock_queue'
        table_name = "CustomerOrders"

        save_to_dynamo(data, table_name)
        send_order_to_sqs(data, sqs_queue_name)

        response = {
            'statusCode': 200,
            'body': json.dumps({'message': 'Order processed successfully'})
        }

        return response

    except Exception as e:
        response = {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

        return response


def save_to_dynamo(order_details, table_name):
    # Saving customer order
    print(f"saving to dynamo {table_name} ", order_details)

    dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
    print('dynamodb', dynamodb)

    table = dynamodb.Table(table_name)
    print("table", table)

    response = table.put_item(
        Item=order_details
    )
    print(f"Saved to {table}")


def send_order_to_sqs(order_details, queue_name):

    sqs = boto3.client('sqs')

    response = sqs.get_queue_url(QueueName=queue_name)
    queue_url = response['QueueUrl']
    print('queue_url', queue_url)

    sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=json.dumps(order_details)
    )
    print('msg send')
