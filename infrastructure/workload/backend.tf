terraform {
  backend "s3" {
    bucket       = "dcc-workload-s3-portfolio-041026"
    key          = "workload/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}