resource "aws_security_group" "allow_web" {
  name        = var.sg_name
  description = "Allow inbound web traffic"
  # vpc_id is optional if using the default VPC of the region, 
  # but best practice might be to look it up.
  # For simplicity as requested, we omit vpc_id to use default.
  
  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow_web"
  }
}
