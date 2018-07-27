output "server_ip" {
  value = "${aws_lightsail_instance.app.public_ip_address}"
}
