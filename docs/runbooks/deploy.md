# Runbook: deploy infrastructure changes

Purpose: change AWS resources safely through the pipeline.
Last tested: **24/11/26**

## How a change flows

- Workload layer (`infrastructure/workload`): branch, pull request, checks
  (`secrets-scan`, `foundation-check`, `workload-plan`), read the plan,
  merge, then `workload-apply` applies it.
- Foundation layer (`infrastructure/foundation`): branch, pull request, format and
  validate checks, merge, then I apply from the laptop (see bootstrap.md).

## Make a workload change

1. Branch, edit `infrastructure/workload`, and run in the dev container:
   `AWS_PROFILE=workload terraform fmt`, `terraform validate`,
   `terraform plan`.
2. Commit, push, open a pull request.
3. Read the plan in the `workload-plan` log; expect only what changed.
4. Merge, then watch `workload-apply`: expect "Apply complete" with the
   counts from the plan.
5. Add a cost-log note if a new service was added.

## Where values live

- Role ARNs: repository secrets `AWS_PLAN_ROLE_ARN` and
  `AWS_APPLY_ROLE_ARN`.
- Account and organization IDs: `terraform.tfvars` in foundation, never
  committed.
- OIDC subject: pinned to the numeric owner and repo IDs.

## A plan or apply reports a missing permission

The apply role's policy lives in foundation.
1. Add the action, scoped as narrowly as possible, in
   `infrastructure/foundation/oidc.tf` through a pull request.
2. Merge and apply foundation from the laptop.
3. Re-run the failed workflow.

## Re-run a failed apply

Fix the cause and re-run the job from the Actions tab. Terraform applies
only what is missing. If the state is locked, see recover.md.

## Roll back

Terraform has no automatic rollback. Revert the pull request with
`git revert`, merge the revert, and the pipeline applies the previous
configuration. Anything deleted that Terraform cannot recreate needs
recover.md.

## Login errors

- "Request ARN is invalid": the secret value is malformed; recreate it with
  `gh secret set` from the CLI output.
- "Not authorized to perform sts:AssumeRoleWithWebIdentity": compare the
  token's `sub` with the trust policy. It contains numeric IDs:
  `repo:OWNER@OWNER_ID/REPO@REPO_ID:pull_request` or
  `...:ref:refs/heads/main`.