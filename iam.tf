# Lambda IAM input role & policy

resource "aws_iam_role" "lambda_ecri_ingest_role" {
  name = var.lambda_ecri_ingest_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_ecri_ingest_policy" {
  name   = var.lambda_ecri_ingest_role_policy
  role   = aws_iam_role.lambda_ecri_ingest_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "dynamodb:PutItem"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:s3:::${var.input_bucket}/*",
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.dynamodb_ecri_table_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ecri_ingest_role_attachment" {
  role       = aws_iam_role.lambda_ecri_ingest_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda IAM audit role & policy

resource "aws_iam_role" "lambda_ecri_audit_role" {
  name = var.lambda_ecri_audit_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_ecri_audit_role_policy" {
  name   = var.lambda_ecri_audit_role_policy
  role   = aws_iam_role.lambda_ecri_audit_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:Query",
          "dynamodb:UpdateItem",
          "s3:PutObject",
          "ses:SendEmail",
          "ses:SendRawEmail",
          "sns:Publish"
        ]
        Effect   = "Allow"
        Resource = [
          "arn:aws:dynamodb:${var.aws_region}:*:table/${var.dynamodb_ecri_table_name}",
          "arn:aws:s3:::${var.audit_bucket}/*",
          "arn:aws:ses:${var.aws_region}:*:identity/*",
          "arn:aws:sns:${var.aws_region}:*:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_ecri_audit_role_attachment" {
  role       = aws_iam_role.lambda_ecri_audit_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}