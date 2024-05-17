


data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/"
  output_path = "${path.module}/lambda/lambda.zip"
}

resource "aws_lambda_function" "sqs_lambda_func" {

    
    filename                       = "${path.module}/lambda/lambda.zip"
    function_name                  = "process-sqs"
    role                           =  aws_iam_role.AWSAccessRole.arn
    handler                        = "index.lambda_handler"
    runtime                        = "python3.8"
    depends_on                     = [aws_iam_role_policy_attachment.lambda_sqs_attachment,aws_sns_topic.topic]

    #source_code_hash = filebase64sha256("lambda_function_payload.zip")

}

resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn = aws_sqs_queue.terraform_queue.arn
  function_name    = aws_lambda_function.sqs_lambda_func.arn

/*
  filter_criteria {
    filter {
      pattern = jsonencode({
        body = {
          #Temperature : [{ numeric : [">", 0, "<=", 100] }]
          Action : ["a","b","c","d"]
        }
      })
    }
  }
  */
}