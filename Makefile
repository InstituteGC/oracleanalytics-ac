.PHONY: ansible terraform

ansible:
	(cd ansible && ansible-playbook -i inventory/hosts.cfg playbook.yaml)

terraform:
	(cd terraform && terraform apply)

ssh:
	ssh -i ansible/.ssh/key.pem ubuntu@$(shell cat ansible/inventory/hosts.cfg | tail -1 | cut -d' ' -f1)
