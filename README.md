# aws-portfolio-lab

A personal AWS portfolio built as a security and cloud learning lab:
a public site protected, monitored and attacked in my own accounts,
all defined as code, for under $5 a month.

Status: work in progress. Live site: coming in Phase 2.

## Progress

| Phase | Focus | Status |
| --- | --- | --- |
| 0 | Account, budgets, repo, decisions | Done |
| 1 | Organization, identity, logging, pipeline | In progress |
| 2 | Site on my own domain | Not started |
| 3 | Backend and log queries | Not started |
| 4 | Detection and first simulations | Not started |
| 5 | Network labs | Not started |
| 6 | Remediation, review, showcase | Not started |

## Target architecture

(Diagram: product, platform, security and labs layers.)
Built so far: three-account Organization, Identity Center sign-in,
log-archive bucket, Terraform state backend.

## Repository map

- `docs/architecture/decisions/` - decision records and index
- `docs/runbooks/` - how to bootstrap, deploy, destroy and recover
- `docs/detections/` - detection write-ups (from Phase 4)
- `docs/network-lab/` - lab reports (from Phase 5)
- `docs/cost-log.md` - monthly spend against the $5 goal
- `infra/` - Terraform
- `site/` - website source
- `lambda/` - backend and automation code

## Working with this repo

Development happens in a dev container (`.devcontainer/`) with pinned
tool versions. AWS access uses IAM Identity Center sign-in; no access
keys are stored. See `docs/runbooks/bootstrap.md` for the one manual
setup step.

## Cost

Goal: at or under $5 a month. Tracking in `docs/cost-log.md`.

## Security

No secrets are committed; gitleaks runs before every commit and in CI.
Account IDs, emails and ARNs are replaced with placeholders in the docs.

## License

MIT