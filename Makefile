# This constructs README.md, including Terraform documentation in its middle.
# THIs requires `terraform-docs` to be installed from: https://github.com/segmentio/terraform-docs

# The sed command below increases the markdown heading level of Terraform docs.
README.md:README.pre_terraform_inputs.md README.post_terraform_inputs.md
	@echo Creating ReadMe with Terraform docs. . .
	cat README.pre_tf_inputs.md >README.md
	echo >>README.md
	terraform-docs --with-aggregate-type-defaults md document . |sed 's/^#/##/g' >>README.md
	echo >>README.md
	cat README.post_tf_inputs.md >>README.md

README.pre_terraform_inputs.md:
README.post_terraform_inputs.md:

