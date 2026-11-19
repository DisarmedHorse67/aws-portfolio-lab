variable "management_account_id" {
  type        = string
  description = "ID of the account that owns the AWS Organization"
}

variable "organization_id" {
  type        = string
  description = "AWS Organizations ID "
}

variable "log_archive_account_id" {
  type        = string
  description = "ID of the account that will be used for log archiving"
}

variable "workload_account_id" {
  type        = string
  description = "ID of the account that will be used for workloads"
}

variable "github_owner" {
  type        = string
  description = "GitHub user or organization that owns the repo"
}

variable "github_repository" {
  type    = string
  default = "aws-portfolio-lab"
}

variable "state_bucket_name" {
  type        = string
  description = "Name of the Terraform state bucket"
}