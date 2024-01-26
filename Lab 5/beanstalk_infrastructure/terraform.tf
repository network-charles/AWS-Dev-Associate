terraform {
  backend "s3" {
    bucket         = "terraform-pipeline-charles-s3"
    key            = "terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "terraform-pipeline-charles-dynamo-db"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
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

