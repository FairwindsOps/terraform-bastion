# This constructs README.md, including Terraform documentation in its middle.
# THIs requires `terraform-docs` to be installed from: https://github.com/segmentio/terraform-docs
# NOte this temporarily uses a Docker image to work around terraform-docs not supporting Terraform 0.12.
# Ref: https://github.com/segmentio/terraform-docs/pull/113/files/ae03fa937304f57adb209eaf966e576178479198..807fa7ef7a01fb2946d772552fe80f49dc7868b7
#
# The sed command below increases the markdown heading level of Terraform docs.
README.md:README.pre_terraform_inputs.md README.post_terraform_inputs.md
	@echo Creating ReadMe with Terraform docs. . .
	cat README.pre_tf_inputs.md >README.md
	echo >>README.md
	docker run --rm -w /terraform -v `pwd`:/terraform cytopia/terraform-docs terraform-docs-012  --with-aggregate-type-defaults md document . |sed 's/^#/##/g' >>README.md
	echo >>README.md
	cat README.post_tf_inputs.md >>README.md

README.pre_terraform_inputs.md:
README.post_terraform_inputs.md:

