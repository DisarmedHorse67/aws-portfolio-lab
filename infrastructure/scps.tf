# Guardrails SCPs for the management account
resource "aws_organizations_policy" "security_guardrails" {
  provider    = aws.management
  name        = "dcc-management-scp-security-guardrails-portfolio-041026"
  description = "Deny leaving org, tampering with audit logging/detectors, and restrict regions."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyLeavingOrganization"
        Effect    = "Deny"
        Action    = [
          "organizations:LeaveOrganization"
        ]
        Resource  = "*"
      },
      {
        Sid       = "DenyCloudTrailAndGuardDutyTampering"
        Effect    = "Deny"
        Action    = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "cloudtrail:UpdateTrail",
          "guardduty:DeleteDetector",
          "guardduty:DisassociateFromMasterAccount"
        ]
        Resource  = "*"
      },
      {
        Sid       = "DenyUnauthorizedRegions"
        Effect    = "Deny"
        NotAction = [
          "cloudfront:*",
          "iam:*",
          "route53:*",
          "support:*",
          "sts:*"
        ]
        Resource  = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "us-east-1"
            ]
          }
        }
      }
    ]
  })
}

# SCPs for the management account to deny high-risk operations performed by the root user.
resource "aws_organizations_policy" "deny_root_user" {
  provider    = aws.management
  name        = "dcc-management-scp-deny-root-actions-portfolio-041026"
  description = "Deny high-risk operations performed by the root user."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyRootUserActions"
        Effect    = "Deny"
        Action    = [
          "iam:CreateUser",
          "iam:CreateAccessKey",
          "iam:CreateLoginProfile",
          "account:DeleteAccount",
          "organizations:RemoveAccountFromOrganization",
          "billing:*"
        ]
        Resource  = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      },
      {
        "Sid": "DenySecurityServiceTampering",
        "Effect": "Deny",
        "Action": [
          "guardduty:StopDataSource",
          "guardduty:DeleteDetector",
          "securityhub:DisableSecurityHub",
          "config:DeleteConfigurationRecorder",
          "config:StopConfigurationRecorder"
        ],
        "Resource": "*"
      },
      {
        "Sid": "DenyUnmanagedInternetGateways",
        "Effect": "Deny",
        "Action": [
          "ec2:CreateInternetGateway"
        ],
        "Resource": "*"
      }
    ]
  })
}

# Link of the security guardrails SCP to the workload account
resource "aws_organizations_policy_attachment" "workload_guardrails" {
  provider  = aws.management
  policy_id = aws_organizations_policy.security_guardrails.id
  target_id = var.workload_account_id
}

# Link of the security guardrails SCP to the log archive account
resource "aws_organizations_policy_attachment" "log_archive_guardrails" {
  provider  = aws.management
  policy_id = aws_organizations_policy.security_guardrails.id
  target_id = var.log_archive_account_id
}