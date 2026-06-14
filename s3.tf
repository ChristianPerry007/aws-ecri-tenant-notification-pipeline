# S3 Bucket input

resource "aws_s3_bucket" "ecri_input_bucket" {
  bucket = var.input_bucket
}

resource "aws_s3_bucket_public_access_block" "ecri_input_bucket_public_access_block" {
  bucket = aws_s3_bucket.ecri_input_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ecri_input_bucket_encryption" {
  bucket = aws_s3_bucket.ecri_input_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

# S3 Bucket audit

resource "aws_s3_bucket" "ecri_audit_bucket" {
  bucket = var.audit_bucket
}

resource "aws_s3_bucket_public_access_block" "ecri_audit_bucket_public_access_block" {
  bucket = aws_s3_bucket.ecri_audit_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ecri_audit_bucket_encryption" {
  bucket = aws_s3_bucket.ecri_audit_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}