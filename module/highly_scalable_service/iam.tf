
resource "aws_iam_role" "AWSAccessRole" {
  name = "AWSAccessRole"

  # Enable the role to get AWS credentials
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["ec2.amazonaws.com",
                    "lambda.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "sns_policy" {
  name = "sns_policy"
  role = aws_iam_role.AWSAccessRole.name

  # Ensure the IAM role has permision to publish to SNS for specific topic
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublishSNSMessage",
        "Effect": "Allow",
        "Action": "sns:Publish",
        "Resource": "arn:aws:sns:${var.region}:${data.aws_caller_identity.current.account_id}:${var.sns_topic}"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_attachment" {
  role       = aws_iam_role.AWSAccessRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

/*
resource "aws_iam_role_policy_attachment" "sns_attachment" {
  role       = aws_iam_role.AWSAccessRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSIoTDeviceDefenderPublishFindingsToSNSMitigationAction"
}*/

resource "aws_iam_role_policy_attachment" "sqs_attachment" {
  role       = aws_iam_role.AWSAccessRole.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}


resource "aws_iam_role_policy_attachment" "lambda_sqs_attachment" {
  role = aws_iam_role.AWSAccessRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_iam_instance_profile" "steve_profile" {
  name = "AWSAccessRole"
  role = aws_iam_role.AWSAccessRole.name
}


data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "pull_source_policy" {
  bucket = var.bucket

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.AWSAccessRole.name}"
        },
        "Action": [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::${var.bucket}",
          "arn:aws:s3:::${var.bucket}/*",
        ]
      }
    ]
  })
}
