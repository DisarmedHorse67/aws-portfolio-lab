# Exam mapping

How this project lines up with the AWS Certified Solutions Architect -
Associate (SAA-C03) exam domains. Each row names something I built and
where to find it in this repository. This file shows hands-on practice;
it is not study material and contains no exam questions.

Domain names and weights follow the published exam guide as I understand
it; check the current official exam guide for the authoritative list.
Task statements are summarized in my own words.

Status: Built, In progress or Planned (with the phase).
Last updated: 2026-11-24

## Domain 1: Design Secure Architectures (30%)

| Area | What I built | Where | Phase | Status |
| --- | --- | --- | --- | --- |
| Secure access to AWS resources | IAM Identity Center sign-in with admin and read-only permission sets; no long-lived access keys for my own use | `docs/architecture/decisions/` (Identity Center record), `docs/runbooks/bootstrap.md` | 1 | Built |
| Secure access to AWS resources | Multi-account Organization with service control policies (deny-list guardrails) | `infrastructure/foundation/scps.tf`, decision record on three accounts | 1 | Built |
| Secure workloads and applications | GitHub Actions deploys through OIDC with two least-privilege roles pinned to the repository's numeric IDs | `infrastructure/foundation/oidc.tf`, OIDC decision record | 1 | Built |
| Data security controls | S3 Block Public Access at account level; log bucket with versioning, default encryption, a delete-deny policy and TLS-only access | `infrastructure/foundation/main.tf` | 1 | Built |
| Logging and auditing | Organization CloudTrail trail delivering to a protected log-archive bucket | `infrastructure/foundation/main.tf` | 1 | Built |
| Secure edge delivery | Private S3 bucket behind CloudFront with Origin Access Control, ACM certificate, security headers | `infrastructure/workload/` | 2 | Planned |
| Threat detection | GuardDuty, IAM Access Analyzer, EventBridge alerts | `infrastructure/workload/`, `docs/detections/` | 4 | Planned |

## Domain 2: Design Resilient Architectures (26%)

| Area | What I built | Where | Phase | Status |
| --- | --- | --- | --- | --- |
| Loosely coupled design | Serverless contact backend: API Gateway, Lambda, DynamoDB, SNS | `lambda/`, `infrastructure/workload/` | 3 | Planned |
| High availability | Two-AZ VPC with public and private subnets | `docs/network-lab/` (LAB-1) | 5 | Planned |
| Recoverability | Versioned Terraform state bucket and a tested recovery procedure | `docs/runbooks/recover.md` | 1 | Built |
| Fault tolerance (design only) | Written multi-region failover design, not deployed | `docs/architecture/` | 6 | Planned |

## Domain 3: Design High-Performing Architectures (24%)

| Area | What I built | Where | Phase | Status |
| --- | --- | --- | --- | --- |
| Content delivery | CloudFront caching, compression and a function for subfolder URLs | `infrastructure/workload/` | 2 | Planned |
| Database choice | DynamoDB in on-demand mode with TTL | `infrastructure/workload/` | 3 | Planned |
| Analytics on logs | Athena over CloudTrail and Flow Logs with partition projection | `docs/detections/queries.md`, `docs/network-lab/` | 3, 5 | Planned |
| Network architecture | VPC routing, Gateway endpoints, peering, private DNS | `docs/network-lab/` (LAB-1 to LAB-4) | 5 | Planned |

## Domain 4: Design Cost-Optimized Architectures (20%)

| Area | What I built | Where | Phase | Status |
| --- | --- | --- | --- | --- |
| Cost control | Budgets, anomaly detection, cost allocation tags and a monthly cost log against a $5 limit | `docs/cost-log.md`, cost-control decision record | 0, 1 | Built |
| Storage cost | Lifecycle rules that expire log files and old object versions | `infrastructure/foundation/main.tf` | 1 | Built |
| Network cost | NAT instance compared with a NAT Gateway, with the numbers written down | `docs/network-lab/` (LAB-2) | 5 | Planned |
| Review | Cost and Well-Architected review at the end of the project | `docs/architecture/` | 6 | Planned |

## Not covered by this project

Services the exam covers that this project does not build, because of cost
or scope: load balancers, Auto Scaling, RDS, and customer-managed KMS
keys. These are covered by study outside this repository.

## How I keep this file current

At the end of each phase I change the status of the rows that phase
finished and add links to the evidence (decision records, runbooks,
write-ups, lab reports).