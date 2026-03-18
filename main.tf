# main.tf

provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "personal_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-personal-vpc"
  }
}

resource "aws_s3_bucket" "personal_bucket" {
  bucket = "mypersonalbucket"
  tags = {
    Name = "mypersonalbucket"
  }
}

resource "aws_iam_role" "admin_role" {
  name = "myfauspersonalAdminRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
resource "aws_iam_policy" "admin_policy" {
  name        = "myfauspersonalAdminPolicy"
  description = "Policy for admin role to manage EC2 and VPC resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ec2:CreateVpc",
        "ec2:DescribeVpcs",
        "ec2:CreateSubnet",
        "ec2:DescribeSubnets",
        "ec2:CreateTags",
        "ec2:RunInstances",
        "ec2:DescribeInstances"
      ]
      Resource = "*"
    }]
  })
}

resource "aws_subnet" "personal_subnet" {
  vpc_id            = aws_vpc.personal_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "my-personal-subnet"
  }
}

resource "aws_instance" "personal_instance" {
  ami                  = "ami-0c94855ba95c71c99" # Amazon Linux 2 AMI (us-east-1)
  instance_type        = "t2.micro"
  subnet_id            = aws_subnet.personal_subnet.id
  iam_instance_profile = aws_iam_role.admin_role.name
  tags = {
    Name = "my-personal-instance"
  }
}

output "vpc_id" {
  value = aws_vpc.personal_vpc.id
}

output "s3_bucket_name" {
  value = aws_s3_bucket.personal_bucket.bucket
}

output "iam_role_name" {
  value = aws_iam_role.admin_role.name
}

output "ec2_instance_id" {
  value = aws_instance.personal_instance.id
}
