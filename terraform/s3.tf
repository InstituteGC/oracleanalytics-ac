resource "aws_s3_bucket" "vendor-bucket" {
  bucket = "${local.prefix}-vendor-bucket"

  tags = {
    Name = "${local.prefix} Vendor Bucket"
  }
}

resource "aws_s3_bucket_public_access_block" "vendor-bucket" {
  bucket = aws_s3_bucket.vendor-bucket.id

  block_public_acls   = false
  block_public_policy = false
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.vendor-bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${aws_s3_bucket.vendor-bucket.arn}/*"
    ]
  }
}

resource "aws_s3_object" "object-jdk" {
  bucket = aws_s3_bucket.vendor-bucket.bucket
  key    = "jdk"

  source = "${path.module}/../vendor/jdk-8u202-linux-x64.tar.gz"

  source_hash = filemd5("${path.module}/../vendor/jdk-8u202-linux-x64.tar.gz")

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_object" "object-fusion-middleware" {
  bucket = aws_s3_bucket.vendor-bucket.bucket
  key    = "fusion-middleware"

  source = "${path.module}/../vendor/V983368-01.zip"

  source_hash = filemd5("${path.module}/../vendor/V983368-01.zip")

  lifecycle {
    ignore_changes  = [source_hash]
    prevent_destroy = true
  }
}

resource "aws_s3_object" "object-oas" {
  bucket = aws_s3_bucket.vendor-bucket.bucket
  key    = "oas"

  source = "${path.module}/../vendor/V1034351-01.zip"

  source_hash = filemd5("${path.module}/../vendor/V1034351-01.zip")

  lifecycle {
    ignore_changes  = [source_hash]
    prevent_destroy = true
  }
}
