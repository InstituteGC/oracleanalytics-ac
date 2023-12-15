.PHONY: ansible terraform

ansible:
	(cd ansible && ansible-playbook -i inventory/hosts.cfg playbook.yaml)

terraform:
	(cd terraform && terraform apply)

ssh:
	ssh -Y -i ansible/.ssh/key.pem ubuntu@$(shell cat ansible/inventory/hosts.cfg | tail -1 | cut -d' ' -f1)

load-sample-data:
	mysql --host=$(shell cd terraform; terraform output -raw db_host) --port=$(shell cd terraform; terraform output -raw db_port) --user=admin --password=Password1 < mysqlsampledatabase.sql
