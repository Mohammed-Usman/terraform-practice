import json
import boto3


def lambda_handler(event, context):
    try:

        order_details = json.loads(event['body'])

        response = {
            'statusCode': 200,
            'body': json.dumps(order_details)
        }

        send_order_to_sqs(order_details, 'process_queue')

        return response

    except Exception as e:
        response = {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
        return response


def send_order_to_sqs(order_details, queue_name):

    sqs = boto3.client('sqs')

    response = sqs.get_queue_url(QueueName=queue_name)
    queue_url = response['QueueUrl']

    sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=json.dumps(order_details)
    )

    print('msg sent')
