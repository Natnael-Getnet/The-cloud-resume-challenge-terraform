import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("visitors-count")


def lambda_handler(event, context):
    item = table.get_item(Key={"id": "0"})
    views = item["Item"]["views"]

    views += 1

    table.put_item(Item={"id": "0", "views": views})

    return views
