terraform {
  required_version = "~> 1.6.3"

  backend "s3" {
    bucket = "hngiap-terraform-remote-state"
    key    = "${{values.application_name}}/tf-state.json"
    region = "us-east-1"
    workspace_key_prefix = "environment"
  }  

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.25.0"
    }
  }
}