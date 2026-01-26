# IAM Role for EC2
resource "aws_iam_role" "ssm_role" {
  name = "jenkins_ssm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
# Attach AmazonSSMManagedInstanceCore policy
resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
# Instance Profile to attach to EC2
resource "aws_iam_instance_profile" "ssm_profile" {
  name = "jenkins_ssm_profile"
  role = aws_iam_role.ssm_role.name
}
