#!/usr/bin/env bash
set -ex

source ./env.sh

create_ssh_cfg()
{
	jump_host_ip=$(terraform output bastion_entrypoint)
	
	echo 'StrictHostKeyChecking no
Host loadbalancer
  Hostname 192.168.2.4
  ProxyCommand ssh -F /etc/ansible/ssh.cfg -W %h:%p jump_host
  IdentityFile /home/ec2-user/ansible.pem
Host bastion
  Hostname 192.168.2.5
  ProxyCommand ssh -F /etc/ansible/ssh.cfg -W %h:%p jump_host
  IdentityFile /home/ec2-user/ansible.pem
Host nginx
  Hostname 192.168.2.7
  ProxyCommand ssh -F /etc/ansible/ssh.cfg -W %h:%p jump_host
  IdentityFile /home/ec2-user/ansible.pem

Host 192.168.2.*
  ProxyCommand ssh -F /etc/ansible/ssh.cfg -W %h:%p jump_host
  IdentityFile /home/ec2-user/ansible.pem

Host jump_host
  Hostname '$jump_host_ip'
  User ec2-user
  IdentityFile /home/ec2-user/ansible.pem
  ControlMaster auto
  ControlPath ~/.ssh/ansible-%r@%h:%p
  ControlPersist 5m' > /etc/ansible/ssh.cfg
}

run_ansible()
{
	ansible-playbook /etc/ansible/all.yml \
	&& ansible-playbook /etc/ansible/nginx.yml \
	&& ansible-playbook /etc/ansible/lb.yml
}



if /sbin/terraform apply ; then
	rm -f /root/.ssh/known_hosts \
	&& create_ssh_cfg ; else
	echo "terraform apply failed"
	exit 1
fi

while true ; do
	if ! ansible all -m ping ; then
		echo "not all hosts are up, retrying in 5 seconds..." && sleep 5 ; else
	run_ansible && exit 0
	fi
done
