terraform {
  required_version = "0.14.8"
  backend "s3" {
    bucket = "quin-terraform-states"
    key    = "flask-app"
    region = "us-west-2"
  }
}