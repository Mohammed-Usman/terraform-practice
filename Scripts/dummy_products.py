import boto3

dynamodb = boto3.resource('dynamodb', region_name="ap-south-1")
table = dynamodb.Table('ProductsInfo')

data = [
    {'product_id': 1, 'name': 'Shoes', "quantity": 100},
    {'product_id': 2, 'name': 'Cap', "quantity": 100},
    {'product_id': 3, 'name': 'Belt', "quantity": 100},
    {'product_id': 4, 'name': 'Shirt', "quantity": 100},
    {'product_id': 5, 'name': 'Laptop', "quantity": 100},
]

for item in data:
    table.put_item(Item=item)

print("Dummy data inserted successfully.")
