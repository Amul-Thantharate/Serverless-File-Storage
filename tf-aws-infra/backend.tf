terraform {
    backend "s3" {
        bucket         = "terraform-state-bucket-122"
        region         = "us-east-1"
        key            = "Serverless-File-Storage/terraform.tfstate"
        dynamodb_table = "terraform-state-lock"
        encrypt        = true
    }

}