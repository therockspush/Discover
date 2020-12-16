output "bootstrap_s3_role" {
  value = aws_iam_role.pan_bootstrap_s3_role.id
}
output "bootstrap_bucket" {
  value = aws_s3_bucket.avtx_panvm_bootstrap.id
}

output "bootstrap_bucket_ha" {
  value = aws_s3_bucket.avtx_panvm_bootstrap_ha.id
}

/*
output "bootstrap_bucket_egress" {
  value = aws_s3_bucket.avtx_panvm_bootstrap_egress.id
}

output "bootstrap_bucket_egress_ha" {
  value = aws_s3_bucket.avtx_panvm_bootstrap_egress_ha.id
}
*/
