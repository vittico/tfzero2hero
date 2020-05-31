provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  region  = "eu-west-1"
  alias   = "drp"
  profile = terraform.workspace
}

variable "test" {
  default = false
}

resource "aws_s3_bucket" "bucket_de_prueba" {
  count = var.test ? 1 : 0
}


