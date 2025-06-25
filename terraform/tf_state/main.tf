resource "aws_s3_bucket" "terraform_state_test" {
  bucket = "exampletodo-terraform-state-bucket"

  tags = {
    Name        = "TerraformState"
    Environment = "State"
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_test" {
  bucket = aws_s3_bucket.terraform_state_test.id

  versioning_configuration {
    status = "Enabled"
  }
}

output "test_terraform_state_bucket_name" {
  value       = aws_s3_bucket.terraform_state_test.bucket
  description = "The name of the S3 bucket used for Test environment Terraform state file"
}