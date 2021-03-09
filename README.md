# Terraform Bastion Modules

These Terraform modules manage an Amazon Web Services (AWS) or Google Cloud Platform (GCP) bastion and its Auto Scaling Group, Identity and Access Management (IAM) resources, remote logging, SSH users and firewall access. The Auto Scaling Group will recreate the bastion if there is an issue with the compute instance or the AWS availability zone where it is running.

The configuration scripts assume the Ubuntu operating system, which is configured as follows:

* Packages are updated, and the bastion is rebooted if required.
* If SSH hostkeys are present in the configurable S3 or GCS bucket and path, they are copied to the bastion to retain its previous SSH identity. If there are no host keys in cloud storage, the current keys are copied there.
* A logging agent is installed and configured to ship logs from these files to AWS or GCP log storage:
	* `/var/log/syslog`
	* `/var/log/auth.log`
* A host record, named using the `bastion_name` module input,  is added to a configurable Route53 or Google DNS zone for the current public IP address of the bastion. This happens via a script configured to run each time the bastion boots.
* Automatic updates are configured, using a configurable time to reboot, and the email address to receive errors.
* By default sudo access is removed from the ubuntu user unless the `remove_root_access` input is set to "false."
* An additional one-time script can be executed, for one-off configuration not included in this module.
* Additional SSH users can be created and populated with their own `authorized_keys` file.

## Using The Modules

Each module has individual development and [releases](https://github.com/FairwindsOps/terraform-bastion/releases). For additional detail, please see the ReadMe for each module:

* [AWS bastion module](./aws/README.md)
* [GCP bastion module](./gcp/README.md)
