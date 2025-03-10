terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  # First, require to deploy S3 & dynamodb 
#   backend "s3" {
#     bucket         	   = "tfstate"
#     key                = "state/terraform.tfstate"
#     region         	   = ""
#     encrypt        	   = true
#     dynamodb_table     = "tf_lockid"
#   }
}

# Configure the AWS Provider
provider "aws" {

}

provider "aws" {
  alias = "DEV"
  region     = var.DEV_AWS_REGION
  access_key = var.DEV_AWS_ACCESS_KEY_ID
  secret_key = var.DEV_AWS_SECRET_ACCESS_KEY
}

provider "aws" {
  alias = "PROD"
  region     = var.PROD_AWS_REGION
  access_key = var.PROD_AWS_ACCESS_KEY_ID
  secret_key = var.PROD_AWS_SECRET_ACCESS_KEY
}
