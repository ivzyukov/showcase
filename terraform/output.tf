output "bastion_entrypoint" {
  depends_on = [
     "aws_eip.bastion"
  ]
  value = "${aws_eip.bastion.public_ip}"
}

output "load_balancer_entrypoint" {
  value = "${aws_eip.lb.public_ip}"
}
