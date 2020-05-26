provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region = "eu-west-1"
  alias = "drp"
  profile = terraform.workspace
}

resource "aws_s3_bucket" "bucket_de_prueba" {
  provider = aws.drp
  provider = ""
}


