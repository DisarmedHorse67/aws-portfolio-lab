# Runbook: recover from problems

Test each procedure on something harmless before relying on it.
Last tested: **24/11/26**

## Stuck state lock

Symptom: "Error acquiring the state lock" with a lock ID.
1. Confirm no run is in progress (Actions tab, local terminals).
2. In the right layer folder: `terraform force-unlock <LOCK_ID>`.
3. If a lock file remains, it is the object `<key>.tflock` in the state
   bucket; delete it only after step 1.

## Restore an earlier state version

1. Back up the current state outside the repo:
   `terraform state pull > backup.json`.
2. List versions:
   `aws s3api list-object-versions --bucket <state-bucket>
   --prefix <key> --profile workload`.
3. Download a good version with `aws s3api get-object` and its
   `--version-id`.
4. Read it first (serial number and resources), then
   `terraform state push <file>`.
5. Run `terraform plan`; expect No changes or only known differences.

## Apply failed halfway

1. Read the error and fix the cause.
2. Run `terraform plan`; it shows what is still missing.
3. If a resource exists in AWS but not in state, `terraform import` it,
   then plan again.

## Locked out of sign-in

Use the root user of the affected account with MFA as the break-glass
route, fix the Identity Center assignment, then stop using root.

## The pipeline cannot log in

Check in order: secret names and values; the trust policy `sub`,
including the numeric IDs; plan role for pull requests and apply role for
`main`; the roles still exist (foundation applied).

## Leaked credential or lost laptop

- Sign out of Identity Center and revoke active sessions where the
  console allows it.
- Revoke GitHub tokens and SSH keys; rotate any exposed secret.
- Rerun gitleaks over the whole history.