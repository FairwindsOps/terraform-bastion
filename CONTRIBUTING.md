# Contributing to Terraform Bastion Modules

Thank you for your interest in improving these modules. Please first discuss any enhancement to this module by opening an issue](https://github.com/FairwindsOps/terraform-bastion/issues), and familiarize yourself with the [design document](./DESIGN.md).

## Requirements for Pull Requests
* Test a `terraform apply` of the changes your pull request introduces, to ensure a good user experience for existing bastions. If you are unsure, please have a discussion in your Github issue or pull request.
* Update the changelog.
	* Suggest a version bump along with your update, see the changelog  for details.
* If you intend to update `README.md`:
	* make changes to one of the `README.*.md` files, instead of changing `README.md`.
	* Install [terraform-docs](https://github.com/segmentio/terraform-docs).
	* Run `make` to generate `README.md`, including Terraform module inputs.
