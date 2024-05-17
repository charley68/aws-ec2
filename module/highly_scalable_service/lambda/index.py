import json
import boto3

client = boto3.client('sns')
print('Loading function')

def lambda_handler(event, context):
    print(json.dumps(event))
    for message in event['Records']:
        process_message(message)
    print("done")

def process_message(message):
    try:
        action = message['body']
        print(f"Processed message {message['body']}")
        
        if action == 'a':
            msg = "You won a car"
        elif action == 'b':
             msg = "You won a house"
        elif action == 'c':
            msg = "You won $50k"
        else:
            msg = "You won sweet fuck all"

        response = client.publish(TopicArn='arn:aws:sns:eu-west-2:868171460502:sns-topic',Message=msg)
        print("Message published")


        # TODO: Do interesting work based on the new message
    except Exception as err:
        print("An error occurred")
        raise err