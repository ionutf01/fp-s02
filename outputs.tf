# ============================================================
# Outputs — uncomment each section after the matching apply
# ============================================================
/*
# ── Phase 1: Network ──

 output "vpc_id" {
   description = "VPC ID"
   value       = aws_vpc.cloudpulse.id
 }

# ── Phase 2: SG Module + S3 ──

 output "s3_bucket_name" {
   description = "S3 bucket name (account-regional)"
   value       = aws_s3_bucket.cloudpulse.id
 }

# ── Phase 3: DynamoDB ──

 output "dynamodb_table_name" {
   description = "DynamoDB table name"
   value       = aws_dynamodb_table.cloudpulse.name
 }

# ── Phase 4: EC2 ──

 output "app_url" {
   description = "Open this in your browser!"
   value       = "http://${aws_instance.cloudpulse.public_ip}"
 }

 output "instance_id" {
   description = "EC2 instance ID"
   value       = aws_instance.cloudpulse.id
 }

 output "account_id" {
   description = "Your AWS account ID"
   value       = data.aws_caller_identity.current.account_id
 }
*/