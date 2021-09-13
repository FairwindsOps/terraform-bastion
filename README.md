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


<!-- Begin boilerplate -->
## Join the Fairwinds Open Source Community

The goal of the Fairwinds Community is to exchange ideas, influence the open source roadmap,
and network with fellow Kubernetes users.
[Chat with us on Slack](https://join.slack.com/t/fairwindscommunity/shared_invite/zt-e3c6vj4l-3lIH6dvKqzWII5fSSFDi1g)
[join the user group](https://www.fairwinds.com/open-source-software-user-group) to get involved!

<a href="https://www.fairwinds.com/t-shirt-offer?utm_source=terraform-bastion&utm_medium=terraform-bastion&utm_campaign=terraform-bastion-tshirt">
  <img src="https://www.fairwinds.com/hubfs/Doc_Banners/Fairwinds_OSS_User_Group_740x125_v6.png" alt="Love Fairwinds Open Source? Share your business email and job title and we'll send you a free Fairwinds t-shirt!" />
</a>

## Other Projects from Fairwinds

Enjoying terraform-bastion? Check out some of our other projects:
* [Polaris](https://github.com/FairwindsOps/Polaris) - Audit, enforce, and build policies for Kubernetes resources, including over 20 built-in checks for best practices
* [Goldilocks](https://github.com/FairwindsOps/Goldilocks) - Right-size your Kubernetes Deployments by compare your memory and CPU settings against actual usage
* [Pluto](https://github.com/FairwindsOps/Pluto) - Detect Kubernetes resources that have been deprecated or removed in future versions
* [Nova](https://github.com/FairwindsOps/Nova) - Check to see if any of your Helm charts have updates available
* [rbac-manager](https://github.com/FairwindsOps/rbac-manager) - Simplify the management of RBAC in your Kubernetes clusters
