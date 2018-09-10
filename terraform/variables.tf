variable "base_ami_id" {
  default = "cmi-6C914150"
}

variable "nr_ami_id" {
  default = "cmi-09349C3D"
}

variable "region" {
  default = "croc"
}

variable "base_cidr_block" {
  default = "192.168.0.0/22"
}

variable "first_cidr_block" {
  default = "192.168.2.0/24"
}
