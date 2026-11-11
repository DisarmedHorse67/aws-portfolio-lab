# Runbook: bootstrap the Terraform state bucket

Purpose: create the one resource Terraform cannot create for itself, the
S3 bucket that stores its state.
Account and Region: workload account, us-east-1.
Last tested: 2026-11-10

## Prerequisites

- Signed in with `aws sso login --profile workload`.
- `aws sts get-caller-identity --profile workload` shows the workload
  account.
- A bucket name that is globally unique and contains no account ID, for
  example `<project>-tfstate-<random-suffix>`.

## Steps

1. Create the bucket (no location constraint is needed in us-east-1):

   ```
   aws s3api create-bucket --bucket <bucket-name> \
     --region us-east-1 --profile workload
   ```

2. Block all public access:

   ```
   aws s3api put-public-access-block --bucket <bucket-name> \
     --public-access-block-configuration \
     BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true \
     --profile workload
   ```

3. Turn on versioning, so an earlier state can be recovered:

   ```
   aws s3api put-bucket-versioning --bucket <bucket-name> \
     --versioning-configuration Status=Enabled --profile workload
   ```

4. Set default encryption:

   ```
   aws s3api put-bucket-encryption --bucket <bucket-name> \
     --server-side-encryption-configuration \
     '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}' \
     --profile workload
   ```

5. Add the project tags:

   ```
   aws s3api put-bucket-tagging --bucket <bucket-name> \
     --tagging 'TagSet=[{Key=project,Value=aws-portfolio-lab},{Key=lifecycle,Value=permanent}]' \
     --profile workload
   ```

## Verify

- `aws s3api get-bucket-versioning --bucket <bucket-name> --profile workload`
  returns `"Status": "Enabled"`.
- `aws s3api get-public-access-block ...` shows all four settings true.
- `aws s3api get-bucket-encryption ...` shows AES256.
- `aws s3api get-bucket-tagging ...` shows both tags.

## Undo

Only if the bucket holds no state: delete all object versions, then
`aws s3api delete-bucket`. If it does hold state, do not delete it; see
the recover runbook.

## Notes

- The bucket name goes in the Terraform backend configuration. Because it
  has no account ID, it is safe to commit.
- Optional: add a lifecycle rule that expires old object versions after a
  number of days, to limit storage.