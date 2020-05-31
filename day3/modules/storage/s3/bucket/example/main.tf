provider "aws" {
  region = "us-east-1"
}
module "test_buecket" {
  source      = "../"
  bucket_name = "test-bucket-qieuewj2u34"
  environment = "academy"
}

module "test_buecket2" {
  source      = "../"
  bucket_name = "test-bucket2-qieuewj2u34"
  environment = "academy"
}