terraform {
  required_version = ">= 1.14.0"
  backend "s3" {
    bucket = ""
    key    = ""
    region = ""
  }
}