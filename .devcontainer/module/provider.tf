terraform {
  required_providers {
    awscc = {
      source = "hashicorp/awscc"
      version = "1.32.0"
    }
  }
}

provider "awscc" {
  region ="ap-south-1"
}