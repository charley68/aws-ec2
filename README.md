

This is a nonsesense application to test out creating multiple AWS resources.

For simplicity, i am using default VPC and default subnets and no LB to save time creating/destroying.

The app uses python FLASK and accepts a few endpoints.

/sqs?Action=xxx

This will post a message onto SQS with Action=xxx.   Lambda will monitor this queue and pull of any new messages.   Lambda will then modify this message depending on the Action name and push
an entry into   dynamoDB or some other DB.

/buckets 

List all S3 buckets


