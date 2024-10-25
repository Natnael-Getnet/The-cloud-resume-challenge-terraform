# Create a S3 bucket
resource "aws_s3_bucket" "the-cloud-resume-challenge-terraform" {
  bucket        = "the-cloud-resume-challenge-terraform"
  force_destroy = true
  tags = {
    Name        = "The cloud resume challenge"
    Environment = "dev"
  }
}
