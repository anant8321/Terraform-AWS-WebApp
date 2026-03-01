terraform {
  backend "s3" {
    bucket = "anant-tf-state-store"
    key = "webapp/prod/terraform.tfstate"        // file path inside the bucket
    region = "ap-south-1"
    dynamodb_table = "my-terraform-locks-tbl"   // distributed lock manager
    encrypt = true  // server side encryption (sse)
  }
}