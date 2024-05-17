

# This workaround is due to a bug where sometimes the queue fails to create
# as role isnt ready yet.  This forces a 60 second wait after role is created
# before the queue is created.
resource "time_sleep" "wait_60_seconds" {
  depends_on = [aws_iam_role.AWSAccessRole]

  create_duration = "60s"
}


resource "aws_sqs_queue" "terraform_queue" {

  depends_on = [  time_sleep.wait_60_seconds ]
  name                      = "SteveProject2Queue"


  # This is the access policy itself on who or what can access this queue
  policy = jsonencode({
    
    "Version": "2012-10-17",
    "Id": "__default_policy_ID",
    "Statement": [
        {
        "Sid": "__owner_statement",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.AWSAccessRole.name}"
        },
        "Action": "SQS:*",
        "Resource": "arn:aws:sqs:eu-west-2:868171460502:SteveProject2Queue"
        }]
  })

  tags = local.tags
}