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

## Second manual step: apply the foundation layer

Why manual: the pipeline cannot log in until its roles exist, and the
roles live in the foundation layer, which the pipeline never applies.
Any change to the pipeline's permissions is applied from the laptop too.

Layer: `infra/foundation` (resources in management, log-archive and
workload accounts). Last tested: <date>

### Prerequisites

- State bucket exists (first section) and `terraform.tfvars` in
  `infra/foundation/` has all values (never committed).
- Signed in to all three profiles: `aws sso login` for `management`,
  `log-archive` and `workload`.

### Steps

1. `cd infra/foundation`
2. `terraform init`, then `terraform plan`. Expect only what you changed;
   stop if anything unexpected appears.
3. `terraform apply`
4. `terraform output` shows `plan_role_arn` and `apply_role_arn`.

### Verify

- The OIDC provider is listed, both trust policies name your exact repo
  with `pull_request` and `refs/heads/main` and contain no `*`, and the
  apply role has only `ReadOnlyAccess` plus its inline policy (the
  commands are in the Phase 1 evidence notes).

### Hand the pipeline its roles

1. In the GitHub repository settings, add the secrets `AWS_PLAN_ROLE_ARN`
   and `AWS_APPLY_ROLE_ARN` from the outputs. Secrets, not variables,
   because the ARNs contain the account ID.
2. Set Actions to require approval for workflows from outside
   contributors.

### Order of work from now on

- Foundation first, from the laptop. Workload second, through a pull
  request.
- When a phase needs the pipeline to create a new kind of resource, widen
  the apply role's policy in foundation, apply it from the laptop, and
  only then merge the workload change.

### Undo

Destroy only the pipeline roles and the OIDC provider, from the laptop:
`terraform destroy -target=<resource>` for each. Do not destroy the log
bucket or the trail this way.