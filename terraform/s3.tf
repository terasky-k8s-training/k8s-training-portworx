# Create S3 bucket
resource "aws_s3_bucket" "backup_bucket" {
  bucket = var.s3_name
}

# Create IAM user
resource "aws_iam_user" "s3_user" {
  name = join("-", [var.s3_name, "user"])
}

# Attach policy granting full access to S3 bucket
resource "aws_iam_user_policy_attachment" "s3_policy_attachment" {
  user       = aws_iam_user.s3_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_policy" "portworx_list_describe" {
  name = "portworx_list_describe-${var.cluster_name}-${random_string.id.result}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "eks:ListClusters",
          "eks:DescribeCluster"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_user_policy_attachment" "admini_access" {
  user       = aws_iam_user.s3_user.name
  policy_arn = aws_iam_policy.portworx_list_describe.arn
}

# Create IAM access key for the user
resource "aws_iam_access_key" "s3_user_access_key" {
  user = aws_iam_user.s3_user.name
}