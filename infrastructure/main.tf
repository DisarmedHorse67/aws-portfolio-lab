locals {
  trail_name = "dcc-portfolio-trail"
  trail_arn  = "arn:aws:cloudtrail:us-east-1:${var.management_account_id}:trail/${local.trail_name}"
}

#Block public access for all S3 buckets in every account.
resource "aws_s3_account_public_access_block" "workload" {
  provider                = aws.workload
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_account_public_access_block" "management" {
  provider                = aws.management
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_account_public_access_block" "logs" {
  provider                = aws.logs
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#Create S3 bucket for log archive in logs account.
resource "aws_s3_bucket" "log_archive_bucket" {
  provider = aws.logs
  bucket   = "dcc-logs-s3-log-archive-portfolio-041026"
}
#Define S3 Bucket policy for blocking public access to the log archive bucket.
resource "aws_s3_bucket_public_access_block" "log_archive_bucket" {
  provider                = aws.logs
  bucket                  = aws_s3_bucket.log_archive_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
#Enable versioning for the log archive bucket.
resource "aws_s3_bucket_versioning" "log_archive_bucket" {
  provider = aws.logs
  bucket   = aws_s3_bucket.log_archive_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
#Enable server-side encryption for the log archive bucket.
resource "aws_s3_bucket_server_side_encryption_configuration" "log_archive_bucket" {
  provider = aws.logs
  bucket   = aws_s3_bucket.log_archive_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
#Policy for ClouTrail to write logs to the log archive bucket and deny deletion of the bucket.
resource "aws_s3_bucket_policy" "log_archive_bucket_policy" {
  provider = aws.logs
  bucket   = aws_s3_bucket.log_archive_bucket.id

  depends_on = [aws_s3_bucket_public_access_block.log_archive_bucket]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.log_archive_bucket.arn
        Condition = {
          StringEquals = { "aws:SourceArn" = local.trail_arn }
        }
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource = [
          "${aws_s3_bucket.log_archive_bucket.arn}/AWSLogs/${var.management_account_id}/*",
          "${aws_s3_bucket.log_archive_bucket.arn}/AWSLogs/${var.organization_id}/*"
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl"  = "bucket-owner-full-control"
            "aws:SourceArn" = local.trail_arn
          }
        }
      },
    {
        Sid       = "DenyObjectDeletes"
        Effect    = "Deny"
        Principal = "*"
        Action    = ["s3:DeleteObject", "s3:DeleteObjectVersion"]
        Resource  = "${aws_s3_bucket.log_archive_bucket.arn}/*"
    },
      {
        Sid       = "DenyBucketDeletion"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:DeleteBucket"
        Resource  = aws_s3_bucket.log_archive_bucket.arn
      },
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.log_archive_bucket.arn,
          "${aws_s3_bucket.log_archive_bucket.arn}/*"
        ]
        Condition = {
          Bool = { "aws:SecureTransport" = "false" }
        }
      }
    ]
  })
}
#Lifecycle configuration for the log archive bucket to delete objects after 90 days and noncurrent versions after 60 days.
resource "aws_s3_bucket_lifecycle_configuration" "log_archive_bucket" {
  provider = aws.logs
  bucket   = aws_s3_bucket.log_archive_bucket.id

  depends_on = [aws_s3_bucket_versioning.log_archive_bucket]

  rule {
    id     = "expire-logs"
    status = "Enabled"
    filter {}

    expiration {
      days = 90
    }
    noncurrent_version_expiration {
      noncurrent_days = 7
    }
    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }

  rule {
    id     = "remove-expired-delete-markers"
    status = "Enabled"
    filter {}

    expiration {
      expired_object_delete_marker = true
    }
  }
}