# Architecture Decision Records (ADRs)

This index documents every architecture, operational, and governance decision taken during the design and implementation of the **aws-portfolio-lab**.

## General Index

| ID | Name | Category | Status |
| :--- | :--- | :--- | :--- |
| [ADR-001](./ADR-001.md) | Use Terraform for Infrastructure as Code | Infrastructure | Accepted |
| [ADR-002](./ADR-002.md) | Using three accounts for management, log-archive, and workload | Governance and Accounts | Accepted |
| [ADR-003](./ADR-003.md) | Using the Paid-Plan for the project | Governance and Costs | Accepted |
| [ADR-004](./ADR-004.md) | Use us-east-1 as the primary Region | Infrastructure | Accepted |
| [ADR-005](./ADR-005.md) | Develop inside a dev container | Environment and Workflows | Accepted |
| [ADR-006](./ADR-006.md) | Register the domain through Route 53 | Network and DNS | Accepted |
| [ADR-007](./ADR-007.md) | Build the site with Hugo | Application and Content | Proposed |
| [ADR-008](./ADR-008.md) | Use Python for Lambda functions and automation | Automation | Proposed |
| [ADR-009](./ADR-009.md) | Publish in English first, Spanish later | Documentation and Content | Accepted |
| [ADR-010](./ADR-010.md) | Public repository under the MIT license | Repository and License | Accepted |
| [ADR-011](./ADR-011.md) | Send alerts by email through SNS | Monitoring and Alerts | Proposed |
| [ADR-012](./ADR-012.md) | Use IAM Identity Center for human access | Security and Identity | Accepted |
| [ADR-013](./ADR-013.md) | Control spending with Budgets, tags and a monthly cost log | Costs and Governance | Accepted |
| [ADR-014](./ADR-014.md) | Split Terraform into foundation and workload layers | Infrastructure | Accepted |
| [ADR-015](./ADR-015.md) | Pin the OIDC trust to numeric owner and repository IDs | Security and Identity | Accepted |

---

## Domain Summary

* **Architecture, Terraform, and Region:** ADR-001, ADR-004, ADR-014
* **Security, Identity, and Multi-Account:** ADR-002, ADR-012
* **FinOps and Cost Governance:** ADR-003, ADR-013
* **Network, Website, and Automation:** ADR-006, ADR-007, ADR-008, ADR-011
* **Development Environments, Repository, and Documentation:** ADR-005, ADR-009, ADR-010