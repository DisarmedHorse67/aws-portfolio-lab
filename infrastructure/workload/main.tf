resource "aws_s3_account_public_access_block" "workload" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

#This comment is a test for the new GitHub Actions workflow to see if it works with the new working-directory
#Test 2