import boto3
import json


def lambda_handler(event, context):

    try:
        print(event)
        product_info_table_name = 'ProductsInfo'

        process_sqs_messages(event, product_info_table_name)

        response = {
            'statusCode': 200,
            'body': json.dumps({'message': 'UpdateStock Lambda executed successfully'})
        }

    except Exception as e:
        response = {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

    return response


def process_sqs_messages(event, table_name):

    order_details = json.loads(event['Records'][0]['body'])
    update_stock_in_dynamodb(order_details, table_name)


def update_stock_in_dynamodb(order_details, table_name):

    print("order_details", order_details)

    dynamodb = boto3.resource('dynamodb', region_name='ap-south-1')
    table = dynamodb.Table(table_name)

    data = order_details
    product_id = data['product_id']

    print("product_id", product_id)
    print("table", table)
    response = table.get_item(Key={"product_id": int(product_id)})
    print("response", response)

    retrieved_item = response.get("Item", {})
    print("retrieved_item", retrieved_item)

    if retrieved_item:

        print("updating item")

        current_stock = retrieved_item.get("quantity")

        new_stock = current_stock - data["quantity"]

        print("new_stock", new_stock)

        response = table.update_item(
            Key={
                'product_id': product_id
            },
            UpdateExpression='SET quantity= :new_stock',
            ExpressionAttributeValues={
                ':new_stock': new_stock
            },
            ReturnValues='ALL_NEW'
        )

    print("response", response)
