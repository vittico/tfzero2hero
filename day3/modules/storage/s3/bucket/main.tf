resource "aws_s3_bucket" "this" {

  bucket = var.bucket_name != null ? "${var.bucket_name}-${var.environment}" : null
  acl    = var.bucket_acl

}