# ============================================================
# CloudPulse Infrastructure — Session 2
# ============================================================
# After uncommenting, run: terraform plan → terraform apply
# ============================================================

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.37"
    }
  }

  # ── SETUP: Remote State Backend ──
  # Uncomment after creating the S3 bucket.
  # Replace YOUR_ACCOUNT_ID with your actual AWS account ID.

  # backend "s3" {
  #   bucket  = "cloudpulse-tfstate-YOUR_ACCOUNT_ID"
  #   key     = "cloudpulse/terraform.tfstate"
  #   region  = "eu-west-1"
  #   encrypt = true
  # }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}


# ============================================================
# PHASE 1: Network — VPC + Subnet + Routes
# ============================================================
/*
resource "aws_vpc" "cloudpulse" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "${var.project_name}-vpc" }
}

resource "aws_internet_gateway" "cloudpulse" {
  vpc_id = aws_vpc.cloudpulse.id
  tags   = { Name = "${var.project_name}-igw" }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.cloudpulse.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true
  tags = { Name = "${var.project_name}-public-subnet" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.cloudpulse.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudpulse.id
  }
  tags = { Name = "${var.project_name}-public-rt" }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
*/

# ============================================================
# PHASE 2: Security Group (module) + S3 (account-regional)
# ============================================================
# NOTE: After uncommenting, run "terraform init" before apply
#       (required because the module is new)
# ============================================================
/*
module "cloudpulse_sg" {
  source      = "./modules/security-group"
  name        = "${var.project_name}-sg"
  description = "Allow HTTP and SSH access for CloudPulse"
  vpc_id      = aws_vpc.cloudpulse.id

  ingress_rules = [
    { description = "HTTP from anywhere", port = 80, cidr_blocks = ["0.0.0.0/0"] },
    { description = "SSH from anywhere",  port = 22, cidr_blocks = ["0.0.0.0/0"] },
  ]

  tags = { Project = var.project_name }
}

locals {
  s3_bucket_name = "${var.s3_bucket_prefix}-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.name}-an"
}

resource "aws_s3_bucket" "cloudpulse" {
  bucket = local.s3_bucket_name
  tags   = { Name = "${var.project_name}-assets" }
}

resource "aws_s3_object" "background" {
  bucket       = aws_s3_bucket.cloudpulse.id
  key          = var.background_image_key
  source       = var.background_image_path
  content_type = "image/jpeg"
}
*/

# ============================================================
# PHASE 3: DynamoDB + Lifecycle
# ============================================================
/*
resource "aws_dynamodb_table" "cloudpulse" {
  name         = var.dynamodb_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = { Name = "${var.project_name}-counter" }
}

resource "aws_dynamodb_table_item" "visits" {
  table_name = aws_dynamodb_table.cloudpulse.name
  hash_key   = aws_dynamodb_table.cloudpulse.hash_key

  item = <<ITEM
{
  "id": {"S": "visits"},
  "count": {"N": "0"}
}
ITEM

  lifecycle {
    ignore_changes = [item]
  }
}
*/

# ============================================================
# PHASE 4: IAM + EC2
# ============================================================
/*
resource "aws_iam_role" "cloudpulse_ec2" {
  name = "${var.project_name}-ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole", Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "cloudpulse_access" {
  name = "${var.project_name}-access-policy"
  role = aws_iam_role.cloudpulse_ec2.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:ListBucket"]
        Resource = [aws_s3_bucket.cloudpulse.arn,
                    "${aws_s3_bucket.cloudpulse.arn}/*"]
      },
      {
        Effect   = "Allow"
        Action   = ["dynamodb:GetItem", "dynamodb:UpdateItem",
                     "dynamodb:PutItem"]
        Resource = aws_dynamodb_table.cloudpulse.arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "cloudpulse" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.cloudpulse_ec2.name
}

resource "aws_instance" "cloudpulse" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [module.cloudpulse_sg.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.cloudpulse.name

  user_data = templatefile("${path.module}/user_data.tftpl", {
    bucket_name = aws_s3_bucket.cloudpulse.id
    table_name  = aws_dynamodb_table.cloudpulse.name
    region      = var.aws_region
    image_key   = var.background_image_key
  })

  tags = { Name = "${var.project_name}-server" }
}
*/