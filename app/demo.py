import socket
from flask import Flask, request

import boto3, json

app = Flask(__name__)

@app.route("/")
def home():
    return "HOME"

@app.route("/hostname/")
def return_hostname():
    return "This is an example wsgi app served from {} to {}".format(socket.gethostname(), request.remote_addr)

@app.route('/buckets')
def list_buckets():
    # Create a Boto3 resource for S3
    s3 = boto3.resource('s3')
    
    # Get the list of buckets
    buckets = [bucket.name for bucket in s3.buckets.all()]
    
    # Return the bucket names
    return {'buckets': buckets}

# Expects    /sqs?action=xxxxxx
@app.route('/sqs', methods=['GET'])
def sqs():
    print("In SQS")
    action = request.args.get('action')
    print(f"Action={action}")
    send_message(action)

    return f"Thankyou.  ACTION: {action} has been requested. "


# Get the queue URL based on QUEUE Name.
def get_queue_url():
    sqs_client = boto3.client("sqs", region_name="eu-west-2")
    response = sqs_client.get_queue_url(
        QueueName="SteveProject2Queue",
    )

    print(f"Queue URL: {response['QueueUrl']}")
    return response["QueueUrl"]

# Push to SQS
def send_message(message):
    print("In Send Message")
    sqs_client = boto3.client("sqs", region_name="eu-west-2")

    print(json.dumps(message))
    response = sqs_client.send_message(
        QueueUrl=get_queue_url(),
        MessageBody=json.dumps(message)
    )
    print(response)

if __name__ == "__main__":
    app.run(host='0.0.0.0', port='80')
