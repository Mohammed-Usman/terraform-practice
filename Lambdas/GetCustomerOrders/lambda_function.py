import boto3
import json
from decimal import Decimal
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Key


def lambda_handler(event, context):

    try:

        dynamodb_credentials = get_secret()

        dynamodb = boto3.resource(
            'dynamodb',
            region_name='ap-south-1',
            aws_access_key_id=dynamodb_credentials['access_key'],
            aws_secret_access_key=dynamodb_credentials['secret_key']
        )

        table_name = 'CustomerOrders'

        customer_id = event['queryStringParameters']['customer_id']

        if customer_id:
            customer = get_order_from_dynamodb(
                dynamodb, table_name, customer_id)

            print('customer', customer)

            response = {
                'statusCode': 200,
                'body': json.dumps(customer, default=decimal_default)
            }

            return response

        else:
            raise ValueError('Missing customer in the event')

    except Exception as e:
        response = {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

    return response


def get_order_from_dynamodb(dynamodb, table_name, customer_id):

    table = dynamodb.Table(table_name)

    filter_expression = Key('customer_id').eq(int(customer_id))

    response = table.scan(
        FilterExpression=filter_expression
    )

    order = response.get('Items', None)

    if order is not None:
        return order
    else:
        raise ValueError(
            f'Order with customer {customer_id} not found in DynamoDB')


def get_secret():

    secret_name = "prod/dynamo"
    region_name = "ap-south-1"

    # Create a Secrets Manager client
    session = boto3.session.Session()
    client = session.client(
        service_name='secretsmanager',
        region_name=region_name
    )

    try:
        get_secret_value_response = client.get_secret_value(
            SecretId=secret_name
        )
    except ClientError as e:
        # For a list of exceptions thrown, see
        # https://docs.aws.amazon.com/secretsmanager/latest/apireference/API_GetSecretValue.html
        raise e

    # Decrypts secret using the associated KMS key.
    secret = get_secret_value_response['SecretString']

    return json.loads(secret)


def decimal_default(obj):
    if isinstance(obj, Decimal):
        return str(obj)
    raise TypeError("Object of type Decimal is not JSON serializable")
