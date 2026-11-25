# Runbook: bootstrap

Purpose: the one-time manual setup that Terraform cannot do for itself.
Related decisions: ADR-014 (Terraform layers), ADR-015 (OIDC subject
pinned to numeric IDs).

Order: Part 1, then Part 2, then Part 3 is reference for later changes.

## Part 1: The Terraform state bucket (manual)

Purpose: create the one resource Terraform cannot create for itself, the
S3 bucket that stores its state.
Account and Region: workload account, us-east-1.
Last tested: **2026-11-10**

### Prerequisites

- Signed in with `aws sso login --profile workload`.
- `aws sts get-caller-identity --profile workload` shows the workload
  account.
- A bucket name that is globally unique and contains no account ID, for
  example `<project>-tfstate-<random-suffix>`.

### Steps

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

### Verify

- `aws s3api get-bucket-versioning --bucket <bucket-name> --profile workload`
  returns `"Status": "Enabled"`.
- `aws s3api get-public-access-block --bucket <bucket-name> --profile workload`
  shows all four settings true.
- `aws s3api get-bucket-encryption --bucket <bucket-name> --profile workload`
  shows AES256.
- `aws s3api get-bucket-tagging --bucket <bucket-name> --profile workload`
  shows both tags.

### Undo

Only if the bucket holds no state: delete all object versions, then
`aws s3api delete-bucket`. If it does hold state, do not delete it; see
the recover runbook.

### Notes

- The bucket name goes in the backend block of each Terraform layer. Because
  it has no account ID, it is safe to commit.
- Each layer uses its own state key in this bucket: `infrastructure/workload` uses
  `workload/terraform.tfstate`, and `infrastructure/foundation` keeps the key it
  had before the split. Check the `key` in each `backend.tf`.
- State locking creates a `<key>.tflock` object next to the state file
  while a run is in progress.
- Optional: add a lifecycle rule that expires old object versions after a
  number of days, to limit storage.

## Part 2: Apply the foundation layer

Why manual: the pipeline cannot log in until its roles exist, and the
roles live in the foundation layer, which the pipeline never applies.
Any change to the pipeline's permissions is applied from the laptop too.

Layer: `infrastructure/foundation` (resources in the management, log-archive and
workload accounts).
Last tested: **24/11/26**

### Prerequisites

- Part 1 is done, and `terraform.tfvars` in `infrastructure/foundation/` has every
  value in the variables table in Part 3 (the file is never committed).
- Signed in to all three profiles: run `aws sso login --profile <name>`
  for `management`, `log-archive` and `workload`.

### Steps

1. `cd infrastructure/foundation`
2. `terraform init`, then `terraform plan`. Expect only what you changed;
   stop if anything unexpected appears.
3. `terraform apply`
4. `terraform output` shows `plan_role_arn` and `apply_role_arn`.

### Verify

Use the role names defined in `oidc.tf` for `<plan-role-name>` and
`<apply-role-name>`.

```
aws iam list-open-id-connect-providers --profile workload

aws iam get-role --role-name dcc-workload-Plan-Role-Portfolio-041026 --profile workload \
  --query Role.AssumeRolePolicyDocument

aws iam get-role --role-name dcc-workload-Apply-Role-Portfolio-041026 --profile workload \
  --query Role.AssumeRolePolicyDocument

aws iam list-attached-role-policies \
  --role-name dcc-workload-Apply-Role-Portfolio-041026 --profile workload
aws iam list-role-policies \
  --role-name dcc-workload-Apply-Role-Portfolio-041026 --profile workload
```

Expected:

- One OIDC provider for `token.actions.githubusercontent.com`.
- Each trust policy has one `aud` condition (`sts.amazonaws.com`) and one
  `sub` condition, both using `StringEquals`, with no `*` anywhere. The
  plan role's `sub` ends in `:pull_request`, and the apply role's ends in
  `:ref:refs/heads/main`.
- The apply role has only `ReadOnlyAccess` attached, plus its inline policy.

### Hand the pipeline its roles

1. In the repository folder, set the secrets from the Terraform outputs.
   Using the terminal avoids copy-paste mistakes (a stray space or line
   break makes the ARN invalid). Run it inside `infrastructure/foundation`, and add
   `-R <owner>/<repo>` if you are not inside the repository:

   ```
   terraform output -raw plan_role_arn  | gh secret set AWS_PLAN_ROLE_ARN
   terraform output -raw apply_role_arn | gh secret set AWS_APPLY_ROLE_ARN
   ```

   They are secrets, not variables, because the ARNs contain the account ID.
2. Set Actions to require approval for workflows from outside
   contributors.

### Order of work from now on

- Foundation first, from the laptop. Workload second, through a pull
  request.
- When a phase needs the pipeline to create a new kind of resource, widen
  the apply role's policy in foundation, apply it from the laptop, and
  only then merge the workload change.

### If the pipeline cannot log in

See `deploy.md` and `recover.md`. The usual causes are a malformed secret
or a `sub` that does not match the trust policy (Part 3).

### Undo

Destroy only the pipeline roles and the OIDC provider, from the laptop:
`terraform destroy -target=<resource>` for each. Do not destroy the log
bucket or the trail this way.

## Part 3: The OIDC trust is pinned to numeric IDs

Last tested: **24/11/26**
The trust policies of both pipeline roles pin the owner and repository by
numeric ID, not only by name. GitHub's token subject has the form
`repo:OWNER@OWNER_ID/REPO@REPO_ID:...`.

- If the repository or owner is renamed, update `github_owner` or
  `github_repository`.
- If the repository is recreated or transferred, the IDs change too.
- Apply foundation again from the laptop in either case.

### Variables for `infrastructure/foundation/terraform.tfvars`

| Variable | What it is | How to get it |
| --- | --- | --- |
| `management_account_id` | ID of the management account | `aws sts get-caller-identity --profile management --query Account --output text` |
| `organization_id` | AWS Organizations ID (starts with `o-`) | `aws organizations describe-organization --profile management --query Organization.Id --output text` |
| `state_bucket_name` | Name of the state bucket from Part 1 | The name you chose in Part 1 |
| `github_owner` | GitHub user or organization name | The first part of the repository URL |
| `github_repository` | Repository name | The second part of the repository URL |
| `github_owner_id` | Numeric ID of the owner | `gh api repos/<owner>/<repo> --jq '.owner.id'` |
| `github_repository_id` | Numeric ID of the repository | `gh api repos/<owner>/<repo> --jq '.id'` |

Never commit the real values. A fake `terraform.tfvars.example` with
placeholder values can be committed.