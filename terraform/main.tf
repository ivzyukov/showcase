# Create a VPC to launch our instances into
resource "aws_vpc" "vol51_vpc" {
  cidr_block = "${var.base_cidr_block}"
}

# Create a subnet to launch our instances into
resource "aws_subnet" "vol51_subnet" {
  vpc_id = "${aws_vpc.vol51_vpc.id}"
  cidr_block = "${var.first_cidr_block}"
  map_public_ip_on_launch = false
}

resource "aws_security_group_rule" "allow_ssh" {
  type = "ingress"
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_security_group_rule" "allow_http" {
  type = "ingress"
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_security_group_rule" "allow_https" {
  type = "ingress"
  from_port = 443
  to_port = 443
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_security_group_rule" "allow_https_8443" {
  type = "ingress"
  from_port = 8443
  to_port = 8443
  protocol = "tcp"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_security_group_rule" "allow_icmp" {
  type = "ingress"
  from_port = 1
  to_port = 1
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  protocol = 1
  security_group_id = "${aws_subnet.vol51_subnet.id}"
}

resource "aws_instance" "loadbalancer" {
  ami = "${var.base_ami_id}"
  subnet_id = "${aws_subnet.vol51_subnet.id}"
  instance_type = "c1.medium"
  monitoring = true
  source_dest_check = false
  availability_zone = "ru-msk-vol51"
  key_name = "ansible"
  private_ip = "192.168.2.4"
  associate_public_ip_address = "false"
  ephemeral_block_device {
    device_name = "cdrom1"
    no_device = "true"
  }
  ebs_block_device {
    device_name = "disk1"
    volume_type = "standard"
    volume_size = "50"
  }
  lifecycle {
    ignore_changes = [
      "ebs_block_device",
      "ephemeral_block_device"]
  }
  provisioner "local-exec" {
    command = "/usr/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.loadbalancer.id} Description.Value loadbalancer"
  }
}

resource "aws_instance" "bastion" {
  ami = "${var.base_ami_id}"
  subnet_id = "${aws_subnet.vol51_subnet.id}"
  instance_type = "c1.medium"
  monitoring = true
  source_dest_check = false
  availability_zone = "ru-msk-vol51"
  key_name = "ansible"
  private_ip = "192.168.2.5"
  associate_public_ip_address = "false"
  ephemeral_block_device {
    device_name = "cdrom1"
    no_device = "true"
  }
  ebs_block_device {
    device_name = "disk1"
    volume_type = "standard"
    volume_size = "50"
  }
  lifecycle {
    ignore_changes = [
      "ebs_block_device",
      "ephemeral_block_device"
    ]
  }
  provisioner "local-exec" {
    command = "/usr/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.bastion.id} Description.Value bastion"
  }
}

resource "aws_instance" "minion" {
  ami = "${var.nr_ami_id}"
  subnet_id = "${aws_subnet.vol51_subnet.id}"
  instance_type = "c1.medium"
  monitoring = true
  source_dest_check = false
  availability_zone = "ru-msk-vol51"
  key_name = "ansible"
  private_ip = "192.168.2.6"
  associate_public_ip_address = "false"
  ephemeral_block_device {
    device_name = "cdrom1"
    no_device = "true"
  }
  ebs_block_device {
    device_name = "disk1"
    volume_type = "standard"
    volume_size = "50"
  }
  lifecycle {
    ignore_changes = [
      "ebs_block_device",
      "ephemeral_block_device"]
  }
  provisioner "local-exec" {
    command = "/usr/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.minion.id} Description.Value minion"
  }
}

resource "aws_instance" "nginx" {
  ami = "${var.base_ami_id}"
  subnet_id = "${aws_subnet.vol51_subnet.id}"
  instance_type = "c1.medium"
  monitoring = true
  source_dest_check = false
  availability_zone = "ru-msk-vol51"
  key_name = "ansible"
  private_ip = "192.168.2.7"
  associate_public_ip_address = "false"
  ephemeral_block_device {
    device_name = "cdrom1"
    no_device = "true"
  }
  ebs_block_device {
    device_name = "disk1"
    volume_type = "standard"
    volume_size = "50"
  }
  lifecycle {
    ignore_changes = [
      "ebs_block_device",
      "ephemeral_block_device"]
  }
  provisioner "local-exec" {
    command = "/usr/bin/c2-ec2 ModifyInstanceAttribute InstanceId ${aws_instance.nginx.id} Description.Value nginx"
  }
}

# Set descritpion for VPC
resource "null_resource" "describe_vpc" {
  depends_on = [
    "aws_vpc.vol51_vpc"
  ]
  provisioner "local-exec" {
    command = "/usr/bin/c2-ec2 ModifyVpcAttribute VpcId ${aws_vpc.vol51_vpc.id} Description.Value showcases"
  }
}

# Assign elastic IPs
resource "aws_eip" "lb" {
  instance = "${aws_instance.loadbalancer.id}"
  vpc = true
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc = true
}
