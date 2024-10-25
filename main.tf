terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a S3 bucket
resource "aws_s3_bucket" "the-cloud-resume-challenge-terraform" {
  bucket = "the-cloud-resume-challenge-terraform"

  tags = {
    Name        = "The cloud resume challenge"
    Environment = "Dev"
  }
}
