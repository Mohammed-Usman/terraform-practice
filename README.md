# Files in the Directory

- Root
  - Infrastructure
    - developement.tf
  - Lambdas
    - CreateOrder
      - lambda_function.py
    - GetCustomerOrders
      - lambda_function.py      
    - ProcessOrder
      - lambda_function.py
    - UpdateStock
      - lambda_function.py
  - Scripts
    - dummy_products.py
    - zipping_Lambdas.py


## Getting Started:

### Step 1 :
- install python 
- install terraform
- Clone this repo and follow steps
 


### Step 2 :
All AWS resources are created in 'ap-south-1' region.
```
cd Infrastructure
open deployement.tf
```
    At the bottom of the deployement.tf file replace following values:

    repalce YOUR_ACCESS_KEY with aws access key
    replace YOUR_SECRET_KEY with aws secret key


### Step 3 :
Create zip files of all lambda functions.
```
cd Scripts
python zipping_lambdas.py
```

### Step 4 :
- Make sure all resources are created in 'ap-south-1', if desired region is different replace all occurance ( in .py and .tf files ) with your desired region and repeat Step #3.
- Run following commands
```
terraform plan -out=tfplan
terraform apply "tfplan"
```
wait unitl all execution is complete


### Step 4 :
- Go to AWS APi Gateway
- Go to MyApi
- Go to Stages
- copy url eg (https://ha7aba3a1znzezwzdze.execute-api.ap-south-1.amazonaws.com/prod)

### Step 5 : 
- single endpoint is used for GET and POST request i.e. /order
- Method POST
```
curl --location 'https://ha7aba3a1znzezwzdze.execute-api.ap-south-1.amazonaws.com/prod/order' \
--header 'Content-Type: application/json' \
--data '{
    "customer_id": 2,
    "order_id": 2,
    "product_id": 2,
    "quantity": 5
}'
```
- Method GET
```
curl --location 'https://h7b31newde.execute-api.ap-south-1.amazonaws.com/prod/order?customer_id=2'
```

<br><br>

# DynamoDB Schema

## ProductInfo Table

| Attribute Name | Type      | Description                         |
| -------------- | --------- | ----------------------------------- |
| product_id       | Number    | Unique identifier for the product      |
| name    | String    | Name of the product          |
| quantity   | Number    | product stock quantity           |


## CustomerOrders Table

| Attribute Name | Type      | Description                         |
| -------------- | --------- | ----------------------------------- |
| order_id     | Number    | Unique identifier for the order    |
| customer_id   | Number    | customer related to an order                   |
| product_id | Number    | product in an order         |
| quantity          | Number    | quantity of a pruduct in an order                 |


