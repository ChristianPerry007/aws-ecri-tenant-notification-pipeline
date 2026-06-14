# Lambda 1 function Ingest from Input Bucket

data "archive_file" "lambda1_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda1_ingest.py"
  output_path = "${path.module}/lambda/lambda1_ingest.zip"
}

resource "aws_lambda_function" "lambda_ecri_ingest_function" {
  function_name = var.lambda_ecri_ingest_function_name
  role          = aws_iam_role.lambda_ecri_ingest_role.arn
  handler       = "lambda1_ingest.lambda_handler"
  runtime       = "python3.14"
  timeout       = 30

  source_code_hash = data.archive_file.lambda1_zip.output_base64sha256

  filename         = data.archive_file.lambda1_zip.output_path

    environment {
        variables = {
        DYNAMODB_TABLE = var.dynamodb_ecri_table_name
        INPUT_BUCKET        = var.input_bucket
        }
    }

    tags = {
    Project     = "ECRI_Notification_ESS"
    Environment = "dev"
    ManagedBy   = "Terraform"
    }
}

# Lambda 1 Trigger from S3 Input Bucket

resource "aws_lambda_permission" "lambda1_s3_permission" {
  statement_id  = "AllowS3InvokeLambda1"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_ecri_ingest_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.ecri_input_bucket.arn
}

resource "aws_s3_bucket_notification" "lambda1_bucket_notification" {
  bucket = aws_s3_bucket.ecri_input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda_ecri_ingest_function.arn
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.lambda1_s3_permission]
}

# Lambda 2 function Audit from DynamoDB to S3, and SES

data "archive_file" "lambda2_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda2_notify.py"
  output_path = "${path.module}/lambda/lambda2_notify.zip"
}

resource "aws_lambda_function" "lambda_ecri_audit_function" {
  function_name = var.lambda_ecri_audit_function_name
  role          = aws_iam_role.lambda_ecri_audit_role.arn
  handler       = "lambda2_notify.lambda_handler"
  runtime       = "python3.14"
  timeout       = 30

  source_code_hash = data.archive_file.lambda2_zip.output_base64sha256

  filename         = data.archive_file.lambda2_zip.output_path

    environment {
        variables = {
        DYNAMODB_TABLE = var.dynamodb_ecri_table_name
        AUDIT_BUCKET   = var.audit_bucket
        SES_SENDER_EMAIL = var.ses_sender_email
        }
    }

    tags = {
    Project     = "ECRI_Notification_ESS"
    Environment = "dev"
    ManagedBy   = "Terraform"
    }
}