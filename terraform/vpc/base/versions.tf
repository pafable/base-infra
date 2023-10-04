module "terraform_aws_version" {
  source = "../../modules/terraform_version"
}

locals {
  common_tags = {
    # keep Name key capitalized so that it will be set in the resource name!
    Name          = var.app_name
    code_location = "terraform/vpc/base"
    email         = var.email
    environment   = data.aws_ssm_parameter.account_env.value
    owner         = var.owner
    project       = "base-infra"
  }
}

terraform {
  backend "s3" {}
}

provider "aws" {
  region = var.region
  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "parameters"
  region = "us-east-1"
}
