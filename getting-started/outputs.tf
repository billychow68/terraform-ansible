# ---------------------------------------------------------------------------------------------------------------------
# outputs
# ---------------------------------------------------------------------------------------------------------------------
# output "eip1" {
#   value = aws_eip.eip1.public_ip
# }
# output "eip2" {
#   value = aws_eip.eip2.public_ip
# }
output "s3_bucket" {
  value = aws_s3_bucket.bucket1.tags.Name
}
output "elb_dns_name" {
  value = "${aws_elb.example.dns_name}"
}
output "security_group" {
  value = aws_security_group.training-app.tags.Name
}
