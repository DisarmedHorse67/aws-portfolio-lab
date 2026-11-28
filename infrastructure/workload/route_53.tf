resource "aws_route53_zone" "main" {
  name = "cybergulio.com"

  lifecycle {
    prevent_destroy = true
  }
}

output "name_servers" {
  value = aws_route53_zone.main.name_servers
}