terraform {
  backend "s3" {
    bucket         = "yldevier-todo-app-dev-terraform-state"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "yldevier-todo-app-dev-terraform-lock"
  }
}
