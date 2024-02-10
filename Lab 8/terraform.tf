terraform {
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.35.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
  }

  required_version = "v1.7.1"
}

# Configure the AWS Provider for Account A
provider "aws" {
  region = "eu-west-2"

  default_tags {
    tags = {
      Provisioned = "Terraform"
    }
  }
}

