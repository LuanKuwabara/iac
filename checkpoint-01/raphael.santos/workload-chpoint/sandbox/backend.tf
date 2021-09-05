terraform {
  backend "s3" {
    bucket  = "iac-be-develop-testes-terraform-rapha"
    encrypt = true
    key     = "iac/2semestre/iac/cp1"
    region  = "us-east-1"
  }
}


