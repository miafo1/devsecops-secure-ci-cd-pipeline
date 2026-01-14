resource "aws_iam_user" "ci_user" {
  name = "devsecops-demo-ci-user"
  path = "/"
}

resource "aws_iam_access_key" "ci_user_key" {
  user = aws_iam_user.ci_user.name
}

# Least privilege policy (mock example)
resource "aws_iam_user_policy" "ci_user_ro" {
  name = "ecr-read-only"
  user = aws_iam_user.ci_user.name

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
      "Resource": "*"
    }
  ]
}
EOF
}
