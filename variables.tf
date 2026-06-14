#S3 Bucket variables

variable "input_bucket" {
  description = "Cx ecri input bucket for with csv list"
  type        = string
  default     = "ecri-input-bucket-cjp"
}

variable "audit_bucket" {
  description = "Cx ecri audit bucket with dynamodb list"
  type        = string
  default     = "ecri-audit-bucket-cjp"
}

# AWS Region variable

variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

# DynamoDB Table variable

variable "dynamodb_ecri_table_name" {
  description = "Name of the DynamoDB table for list records"
  type        = string
  default     = "ecri-dynamodb-table-cjp"
}

# IAM Role & Policy variables

variable "lambda_ecri_ingest_role" {
  description = "This is for the lambda function to access the ingest bucket"
  type        = string
  default     = "lambda-ecri-ingest-iam-role-cjp"
}

variable "lambda_ecri_ingest_role_policy" {
  description = "This is for the lambda function to get objects from the ingest bucket"
  type        = string
  default     = "lambda-ecri-ingest-iam-policy-cjp"
}

variable "lambda_ecri_audit_role" {
  description = "This is for the lambda function to access the dynamodb table and store the data in the s3 bucket with the audit list"
  type        = string
  default     = "lambda-ecri-audit-iam-role-cjp"
}

variable "lambda_ecri_audit_role_policy" {
    description = "This is for the lambda function to access the dynamodb table and put them into sns & ses for notifications and s3 bucket for audit list"
    type        = string
    default     = "lambda-ecri-audit-iam-policy-cjp"
}


# SES Sender and Email variable
variable "ses_sender_email" {
  description = "Email address used as the sender in SES notifications"
  type        = string
}

# Lambda function variables
variable "lambda_ecri_ingest_function_name" {
  description = "Name of the Lambda function for processing input bucket events"
  type        = string
  default     = "lambda-ecri-ingest-function-cjp"
}

variable "lambda_ecri_audit_function_name" {
  description = "Name of the Lambda function for processing audit events from S3, SNS, and SES"
  type        = string
  default     = "lambda-ecri-audit-function-cjp"
}

# Lambda 1 Permission and Trigger variable

variable "lambda1_s3_trigger_permission" {
  description = "Permission for S3 to invoke Lambda 1"
  type        = string
  default     = "AllowS3InvokeLambda1"
}

variable "lambda1_bucket_notification" {
  description = "notification for lambda 1 to be triggered from s3 bucket"
  type        = string
  default     = "ecri-input-bucket-lambda1-notification-cjp"
}


# EventBridge Variables

variable "eventbridge_cloudwatch_rule_name" {
  description = "Name of the EventBridge rule to trigger the Lambda function on a schedule"
  type        = string
  default     = "ecri-eventbridge-cloudwatch-rule-cjp"
}

variable "eventbridge_cloudwatch_target_id" {
  description = "ID for the Lambda function target in the EventBridge rule"
  type        = string
  default     = "ecri-eventbridge-cloudwatch-target-cjp"
}

variable "aws_lambda_permission_eventbridge" {
  description = "Permission for EventBridge to invoke the Lambda function"
  type        = string
  default     = "ecri-lambda-eventbridge-permission-cjp"
}
