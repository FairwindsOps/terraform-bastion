# Terraform Bastion Modules

## Intent

These `bastion` Terraform modules are intended to manage a bastion instance to provide:

* SSH access to Kubernetes nodes which do not have a public IP address.
* API access to a private Kubernetes endpoint.
* Push-button / easy provisioning as part of provisioning other core infrastructure resources (VPC, subnets).
* Separate Terraform modules for Amazon Web Services (AWS) and Google Cloud (GCP), which are as close in their usage and functionality as possible.

## Key Design Features

The bastion should be created in any availability zone used by the AWS VPC or GCP network, and should heal in the event of an availability zone outage. SSH logs should additionally be stored outside the bastion, for good auditing practices and to retain logs if the bastion instance is recreated. The bastion should automatically update operating system packages and reboot as needed when a new kernel is installed.

## Future Direction

Future goals of this project include, in no particular order:

* Support other clouds?