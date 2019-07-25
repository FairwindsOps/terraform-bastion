# Contributing

Thank you for your interest in improving this module.

Please also familiarize yourself with the [design document](./DESIGN.md) to best align any contributions with the goals of this project. If you would like to discuss an enhancement to this module, feel free to [open an issue](https://github.com/FairwindsOps/terraform-bastion/issues).

## Requirements for Pull Requests
* Test a `terraform apply` of changes your pull request introduces, to ensure a good user experience for existing bastions. If you are unsure, please open an issue or discuss in your pull request.
* Update the changelog.
	* Suggest a version bump along with your update, see the changelog  for details.
* IF you intend to update `README.md`:
	* make changes to one of the `README.*.md` files.
	* Install [terraform-docs](https://github.com/segmentio/terraform-docs).
	* Run `make` to generate `README.md`.
