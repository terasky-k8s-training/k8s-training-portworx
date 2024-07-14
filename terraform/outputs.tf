output "cluster_name" {
  description = "The EKS cluster name"
  value       = var.cluster_name
}

output "region" {
  description = "The EKS cluster region"
  value       = var.region
}

output "s3_name" {
  description = "The S3 name"
  value       = var.s3_name
}

output "s3_user" {
  description = "The S3 user's name"
  value       = aws_iam_user.s3_user.name
}

output "s3_user_access_key_id" {
  description = "The access key ID for the S3 user"
  value       = aws_iam_access_key.s3_user_access_key.id
}

output "s3_user_access_key_secret" {
  description = "The secret access key for the S3 user"
  value       = aws_iam_access_key.s3_user_access_key.secret
  sensitive = true
}
