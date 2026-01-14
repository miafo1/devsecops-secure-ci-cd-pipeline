resource "aws_iam_role" "ci_role" {
  name = "devsecops-demo-ci-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      }
    ]
  })
}

# Least privilege role policy (mock example)
resource "aws_iam_role_policy" "ci_role_ro" {
  name = "ecr-read-only"
  role = aws_iam_role.ci_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:ecr:*:*:repository/*"
    }
  ]
}
EOF
}

# Instance profile for attaching role to EC2 instances in mock infra
resource "aws_iam_instance_profile" "ci_instance_profile" {
  name = "ci-instance-profile"
  role = aws_iam_role.ci_role.name
}
