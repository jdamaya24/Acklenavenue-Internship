# ALB DNS Name
output "aa_lb_dns_name" {
  value = aws_lb.aa_lb.dns_name
}

# EC2 Pulic IPs
output "aa_ec2_1_public_ip" {
  value = aws_instance.aa_ec2_1.public_ip
}

output "aa_ec2_2_public_ip" {
  value = aws_instance.aa_ec2_2.public_ip
}
