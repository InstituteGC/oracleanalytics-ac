[instances]
${ip} ansible_ssh_private_key_file=.ssh/key.pem ansible_user=ubuntu ansible_ssh_common_args='-o StrictHostKeyChecking=no'
