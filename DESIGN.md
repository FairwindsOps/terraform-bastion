# Terraform Bastion Module

## Intent

The `bastion` Terraform module is intended to manage a bastion instance to provide:

* SSH access to Kubernetes nodes which do not have a public IP address.
* API access to a private Kubernetes cluster which uses an internal load balancer.
* Push-button / easy provisioning as part of provisioning other base resources (VPC, subnets).

## Key Design Features

The bastion should be created in any availability zone used by the VPC, and should heal in the event of an availability zone outage. SSH logs should additionally be stored outside the bastion, for good auditing practices and to retain logs if the bastion instance is recreated. The bastion should automatically update operating system packages and reboot as needed when a new kernel is installed.

## Future DIrection

Future goals of this project include, in no particular order:

* Manage a bastion in Google Cloud:
* Provide [Cloud DNS](https://cloud.google.com/dns/docs/) as an option to manage the bastion DNS record.
* Provide [Stackdriver](https://cloud.google.com/logging/) as an option to store logs outside of the bastion instance.
