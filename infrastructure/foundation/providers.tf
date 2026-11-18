terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket  = "dcc-workload-s3-portfolio-041026"
    key     = "portfolio/terraform.tfstate"
    region  = "us-east-1"
    profile = "workload"
    encrypt = true
  }
}

provider "aws" {
  alias   = "workload"
  region  = "us-east-1"
  profile = "workload"

  default_tags {
    tags = {
      project   = "aws-portfolio-lab"
      lifecycle = "permanent"
    }
  }
}

provider "aws" {
  alias   = "management"
  region  = "us-east-1"
  profile = "management"

  default_tags {
    tags = {
      project   = "aws-portfolio-lab"
      lifecycle = "permanent"
    }
  }
}

provider "aws" {
  alias   = "logs"
  region  = "us-east-1"
  profile = "logs"

  default_tags {
    tags = {
      project   = "aws-portfolio-lab"
      lifecycle = "permanent"
    }
  }
}