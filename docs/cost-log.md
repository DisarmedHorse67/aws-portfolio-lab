# Cost log

Budget: $5.00 per month.
Hard stop: if forecast spend passes $5, destroy everything tagged
`lifecycle=lab` and start no new lab until next month.
Figures come from the Billing console and Cost Explorer (grouped by
service; data can lag by about a day). No account IDs in this file.

## Budget lines (from the plan)

| Line                                       | Planned | Ceiling |
| ---                                           | ---  |  --- |
| Domain registration                           | 1.00 | 1.00 |
| Route 53 hosted zone                          | 0.50 | 0.50 |
|             Site and backend                  | 0.50 | 0.75 |
| S3, CloudFront, Lambda, DynamoDB, API Gateway | ----------- |
| SNS, EventBridge, CloudFront Functions        | ----------- |
|             Log and analysis                  | 0.50 | 0.75 |
| CloudTrail, log storage, Athena               | ----------- |
| Glue Data Catalog, CloudWatch Logs            | ----------- |
| GuardDuty                                     | 0.75 | 1.00 |
|              Lab sessions                     | 0.50 | 1.00 |
| EC2, EBS, Elastic IPs and Public IPv4         | ----------- |
| VPC Flow Logs, data transfer during labs      | ----------- |
|            Other / Unmapped                   | ----------- |
| ---                                           | ----------- |
| **Total**                                 | **3.75** | **5.00** |

Service-to-line mapping: write once which AWS services you count
under each line.

## 11-2026

Status: in progress 
Month total: $0.00 of $5.00

| Line                                 | Planned | Ceiling | Actual | Note |
| ---                                           | --- | --- | --- | --- |
| Domain registration                           | 1.00 | 1.00 | 0.0 | --- |
| Route 53 hosted zone                          | 0.50 | 0.50 | 0.0 | --- |
|             Site and backend                  | 0.50 | 0.75 | 0.0 | --- |
| S3, CloudFront, Lambda, DynamoDB, API Gateway | ----------- | --------- |
| SNS, EventBridge, CloudFront Functions        | ----------- | --------- |
|             Log and analysis                  | 0.50 | 0.75 | 0.0 | --- |
| CloudTrail, log storage, Athena               | ----------- | --------- |
| Glue Data Catalog, CloudWatch Logs            | ----------- | --------- |
| GuardDuty                                     | 0.75 | 1.00 | 0.0 | --- |
|              Lab sessions                     | 0.50 | 1.00 | 0.0 | --- |
| EC2, EBS, Elastic IPs and Public IPv4         | ----------- | --------- | 
| VPC Flow Logs, data transfer during labs      | ----------- | --------- |
|            Other / Unmapped                   | ----------- | --- | --- |
| ---                                           | ----------- | --------- |
| ---                                           | --- | --- | --- | --- |
| **Total**                                 | **3.75** | **5.00** | | |

### Checkpoints

- 2026-11-04, end of Phase 0: baseline $0.00, alerts set at $1, $3, $5.

### Lab sessions

| Date | Lab | Hours up | Est. cost | Destroyed and verified? |
| ---- | --- | -------- | --------- | ----------------------- |

### Alerts and anomalies

- 

### Lessons and changes

- aa