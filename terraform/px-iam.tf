resource "random_string" "id" {
  length  = 4
  special = false
  upper   = false
}

resource "aws_iam_policy" "portworx_eksblueprint_volume_access" {
  name = "portworx_volumeAccess-${var.cluster_name}-${random_string.id.result}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:AttachVolume",
          "ec2:ModifyVolume",
          "ec2:DetachVolume",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteTags",
          "ec2:DeleteVolume",
          "ec2:DescribeTags",
          "ec2:DescribeVolumeAttribute",
          "ec2:DescribeVolumesModifications",
          "ec2:DescribeVolumeStatus",
          "ec2:DescribeVolumes",
          "ec2:DescribeInstances",
          "autoscaling:DescribeAutoScalingGroups"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "px-policy" {
  for_each = module.eks_blueprints.managed_node_groups[0]
  policy_arn = aws_iam_policy.portworx_eksblueprint_volume_access.arn
  role = each.value.managed_nodegroup_iam_role_name[0]

  depends_on = [
    module.eks_blueprints.eks_managed_node_groups
  ]
}