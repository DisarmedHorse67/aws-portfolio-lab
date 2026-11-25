# Cost log

Budget: $5.00 per month.
Hard stop: if forecast spend passes $5, destroy everything tagged
`lifecycle=lab` and start no new lab until next month.
Figures come from the Billing console and Cost Explorer (grouped by
service; data can lag by about a day). No account IDs in this file.

## Budget lines (from the plan)

| Line | Planned | Ceiling |
| --- | --- | --- |
| Domain registration | 1.00 | 1.00 |
| Route 53 hosted zone | 0.50 | 0.50 |
| Site and backend | 0.50 | 0.75 |
| Logging and analysis | 0.50 | 0.75 |
| GuardDuty | 0.75 | 1.00 |
| Lab sessions | 0.50 | 1.00 |
| Other / unmapped | 0.00 | 0.00 |
| **Total** | **3.75** | **5.00** |

## Service-to-line mapping

| Line | AWS services counted here |
| --- | --- |
| Domain registration | Route 53 domain registration |
| Route 53 hosted zone | Route 53 hosted zone and DNS queries |
| Site and backend | S3 (site bucket), CloudFront, CloudFront Functions, Lambda, DynamoDB, API Gateway, SNS, EventBridge |
| Logging and analysis | CloudTrail, S3 (log-archive and Athena results buckets), Athena, Glue Data Catalog, CloudWatch Logs |
| GuardDuty | GuardDuty |
| Lab sessions | EC2, EBS, Elastic IPs and public IPv4 addresses, VPC Flow Logs, data transfer during labs, lab Route 53 private zone |
| Other / unmapped | Anything not listed above, with a note saying what it was |

## 2026-11

Status: in progress
Month total: $0.14 of $5.00

| Line | Planned | Ceiling | Actual | Note |
| --- | --- | --- | --- | --- |
| Domain registration | 1.00 | 1.00 | 0.00 | |
| Route 53 hosted zone | 0.50 | 0.50 | 0.00 | |
| Site and backend | 0.50 | 0.75 | 0.00 | |
| Logging and analysis | 0.50 | 0.75 | 0.14 | S3 Requests-Tier1 ($0.13) y Requests-Tier2 ($0.01) associated to active log bucket |
| GuardDuty | 0.75 | 1.00 | 0.00 | |
| Lab sessions | 0.50 | 1.00 | 0.00 | |
| Other / unmapped | 0.00 | 0.00 | 0.00 | |
| **Total** | **3.75** | **5.00** | **0.14** | |

### Checkpoints

- 2026-11-04, end of Phase 0: baseline $0.00, alerts set at $1, $3, $5.
- 2026-11-24, end of Phase 1: month to date $0.14.

### Lab sessions

| Date | Lab | Hours up | Est. cost | Destroyed and verified? |
| --- | --- | --- | --- | --- |

### Alerts and anomalies

- Cost Anomaly detected an impact with S3 between november 12 to 16 
  of $0.05,this because a spend of $0.00 was expected, so it's normal
  and doesn't represent any security or configuration issue.

### Lessons and changes

- 

### Month-end reconciliation

- [ ] Cost Explorer grouped by service: every charge is placed in a line.
- [ ] The lines add up to the bill total (or the difference is explained).
- [ ] "Other / unmapped" is $0.00, or its cause is written in the note.