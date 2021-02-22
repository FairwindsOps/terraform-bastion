# This constructs README.md, including Terraform documentation in its middle.
README.md:README.pre_terraform_inputs.md README.post_terraform_inputs.md
	@echo Creating ReadMe with Terraform docs. . .
	cat README.pre_tf_inputs.md >README.md
	echo >>README.md
	docker run --rm -w /terraform -v `pwd`:/terraform cytopia/terraform-docs terraform-docs-012 md document --indent 3 . >>README.md
	echo >>README.md
	cat README.post_tf_inputs.md >>README.md

README.pre_terraform_inputs.md:
README.post_terraform_inputs.md:

