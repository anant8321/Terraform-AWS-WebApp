# allowing EC2 instances to talk to AWS services without using passwords or access keys

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({ // hcl -> json
    Version = "2012-10-17"
    Statement = [{
        Effect = "Allow"
        Principal = {       // who can assume this role
            Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_access" {
  name = "${var.project_name}-s3-access"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::anant-monitoring-app/*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "s3_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access.arn
}

# Attaching CloudWatch Policy to this ec2_role
resource "aws_iam_role_policy_attachment" "cloudwatch" {
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    role = aws_iam_role.ec2_role.name
}

# Instance Profile (required by EC2)
resource "aws_iam_instance_profile" "ec2_profile" {
  role = aws_iam_role.ec2_role.name
  name = "${var.project_name}-instance-profile"
}