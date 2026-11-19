locals {
  github_repo = "${var.github_owner}/${var.github_repository}"
  oidc_host   = "token.actions.githubusercontent.com"
  github_sub  = "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}"
}

resource "aws_iam_openid_connect_provider" "github" {
  provider       = aws.workload
  url            = "https://${local.oidc_host}"
  client_id_list = ["sts.amazonaws.com"]
}

# Trust: plan role, only for pull requests from this repo
data "aws_iam_policy_document" "plan_trust" {
  provider = aws.workload
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["${local.github_sub}:pull_request"]
    }
  }
}

# Trust: apply role, only for the main branch of this repo
data "aws_iam_policy_document" "apply_trust" {
  provider = aws.workload
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_host}:sub"
      values   = ["${local.github_sub}:ref:refs/heads/main"]
    }
  }
}

# State access: plan can read state and manage the lock file only
data "aws_iam_policy_document" "plan_state" {
  provider = aws.workload
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}"]
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}/*"]
  }
  statement {
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}/*.tflock"]
  }
}

# Apply: state read and write, plus the first narrow write permissions
data "aws_iam_policy_document" "apply_permissions" {
  provider = aws.workload
  statement {
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}"]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${var.state_bucket_name}/*"]
  }
  statement {
    actions   = ["s3:PutAccountPublicAccessBlock"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "plan" {
  provider           = aws.workload
  name               = "github-actions-plan"
  assume_role_policy = data.aws_iam_policy_document.plan_trust.json
}

resource "aws_iam_role" "apply" {
  provider           = aws.workload
  name               = "github-actions-apply"
  assume_role_policy = data.aws_iam_policy_document.apply_trust.json
}

resource "aws_iam_role_policy_attachment" "plan_readonly" {
  provider   = aws.workload
  role       = aws_iam_role.plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "apply_readonly" {
  provider   = aws.workload
  role       = aws_iam_role.apply.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy" "plan_state" {
  provider = aws.workload
  name     = "state-access"
  role     = aws_iam_role.plan.id
  policy   = data.aws_iam_policy_document.plan_state.json
}

resource "aws_iam_role_policy" "apply_permissions" {
  provider = aws.workload
  name     = "apply-permissions"
  role     = aws_iam_role.apply.id
  policy   = data.aws_iam_policy_document.apply_permissions.json
}
