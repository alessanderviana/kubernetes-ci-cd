output "instance_priv_ips" {
  value = ["${aws_instance.ubuntu.*.private_ip}"]
}

output "instance_pub_ips" {
  value = ["${aws_instance.ubuntu.*.public_ip}"]
}
