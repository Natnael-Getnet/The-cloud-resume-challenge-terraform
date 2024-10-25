# Create a S3 bucket policy for CloudFront access
resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.the-cloud-resume-challenge-terraform.id
  policy = data.aws_iam_policy_document.allow_access_from_cloudfront.json
}

data "aws_iam_policy_document" "allow_access_from_cloudfront" {
  statement {
    sid    = "AllowCloudFrontServicePrincipal"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = ["s3:GetObject"]

    resources = [
      "${aws_s3_bucket.the-cloud-resume-challenge-terraform.arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.crc_distribution.id}"]
    }
  }
}

data "aws_caller_identity" "current" {}
