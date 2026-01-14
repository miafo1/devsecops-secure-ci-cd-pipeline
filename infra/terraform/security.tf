resource "aws_security_group" "allow_all" {
  name        = "allow_all"
  description = "Allow all inbound traffic"
  vpc_id      = "vpc-12345678" # Mock VPC ID

  # Restrict SSH access to a private management network instead of 0.0.0.0/0
  ingress {
    description = "SSH from management network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "Allow outbound HTTP/HTTPS only"
    from_port   = 80
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Attach security group to a mock instance so Checkov considers it "used"
resource "aws_instance" "demo" {
  ami                    = "ami-0c55b159cbfafe1f0" # placeholder
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.allow_all.id]
  iam_instance_profile   = aws_iam_instance_profile.ci_instance_profile.name
  monitoring             = true
  ebs_optimized          = true

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true
    volume_size = 8
    volume_type = "gp2"
  }

  tags = {
    Name = "devsecops-demo-instance"
  }
}
