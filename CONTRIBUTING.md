# Contributing to Terraform Bastion Modules

Thank you for your interest in improving this module. Please start by discussing enhancements or fixes in a [new Github issue](https://github.com/FairwindsOps/terraform-bastion/issues), which allows everyone to agree on a proposal before work begins. We recommend new issues include:

* A summary of the motivation or context for the change.
* Backward compatibility / migration requirements.
* An example of how to use a new feature or reproduce a problem you are experiencing.
Please see also the [design document](./DESIGN.md).

## Requirements for Pull Requests
* Test a `terraform apply` of the changes your pull request introduces, to ensure a good user experience for existing bastions. If you are unsure, please have a discussion in your Github issue first.
* Update the changelog.
	* Suggest a version bump along with your update, see the changelog  for details.
* If you intend to update `README.md`:
	* make changes to one of the `README.*.md` files, instead of changing `README.md`.
	* Run `make` to generate `README.md`, including Terraform module inputs. This uses Docker to run a specific version of [terraform-docs](https://github.com/segmentio/terraform-docs).
