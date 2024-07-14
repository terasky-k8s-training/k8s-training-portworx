# Create S3 bucket
resource "aws_s3_bucket" "backup_bucket" {
  bucket = var.s3_name
}

# Create IAM user
resource "aws_iam_user" "s3_user" {
  name = join("-", [var.s3_name, "-user"])
}

# Attach policy granting full access to S3 bucket
resource "aws_iam_user_policy_attachment" "s3_policy_attachment" {
  user       = aws_iam_user.s3_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Create IAM access key for the user
resource "aws_iam_access_key" "s3_user_access_key" {
  user = aws_iam_user.s3_user.name
}