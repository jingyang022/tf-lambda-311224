provider "aws" {
  region = "ap-southeast-1"
}

provider "aws" {
  region     = "us-east-1"
  alias      = "virginia"
}