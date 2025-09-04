terraform {
  backend "s3" {
    bucket         = "<AWS_S3_TFSTATE_BUCKET>"
    key            = "multi-cloud/aws/eks.tfstate"
    region         = "<AWS_REGION>"
    dynamodb_table = "<AWS_DYNAMODB_LOCK_TABLE>"
    encrypt        = true
  }
}