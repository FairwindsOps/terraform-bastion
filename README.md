# Terraform Bastion Module

This module manages an Amazon Web Services bastion EC2 instance and its Auto Scaling Group, Instance Profile / Role, CloudWatch Log Group, Security Group, and SSH Key Pair. The Auto Scaling Group will recreate the bastion if there is an issue with the EC2 instance or the availability zone where it is running.

The Ubuntu 18.04 EC2 instance is configured as follows:

* Packages are updated, and the bastion is rebooted if required.
* If SSH hostkeys are present in the configurable S3 bucket and path, they are copied to the bastion to retain its previous SSH identity. If there are no host keys in S3, the current keys are copied there.
* The [CloudWatch Logs Agent][] is installed and configured to ship logs from these files:
	* `/var/log/syslog`
	* `/var/log/auth.log`
* A host record, named using the `bastion_name` module input,  is added to a configurable Route53 DNS zone for the current public IP address of the bastion. This happens via a script configured to run on boot.
* Automatic updates are configured, using a configurable time to reboot, and the email address to receive errors.
* By default sudo access is removed from the ubuntu user unless the `remove_root_access` input is set to "false."

## Using The Bastion
### SSH Access to Kubernetes Nodes

To proxy SSH connections to Kubernetes nodes through the bastion, add configuration like the following to the top of the `ssh_config` file. Replace the following information with your own values:

* `domain.com` with the same **domain name** that was specified as a Route53 zone ID in the instance of the bastion Terraform module. This is the domain name where the bastions host record will have been created during boot.
* `/path/to/ssh/private/key` with the path to your SSH private key file.
* `172.20.*.*` with the VPC CIDR.

```
# Define options to be used when connecting to the bastion.
host bastion.domain.com
  IdentityFile /path/to/ssh/private/key
  IdentitiesOnly yes
  User ubuntu

# Use the bastion to proxy SSH connections to IPs in the VPC
# You can also add a DNS wildcard to the end of the next line
# if you use DNS resolution to access Kubernetes nodes.
host 172.20.*.*
  ProxyCommand ssh -i /path/to/ssh/private/key ubuntu@bastion.domain.com -W %h:%p
```

You can now SSH directly to IP addresses within `172.20.0.0/16`, and your connection will be proxied through the bastion.


### Accessing a Private Kubernetes API 

You can proxy access to a private Kubernetes API through the bastion, instead of using a VPN.

Run the following to forward connections from port 8443 on your workstation, to a private Kubernetes API, - replace `api.clustername.domain.com` with your private API hostname, and `bastion.domain.com` with the hostname of your bastion:

```
ssh -L 8443:api.clustername.domain.com:443 ubuntu@bastion.domain.com
```

In another terminal tab, edit your KubeConfig and replace `api.clustername.domain.com` with `127.0.0.1:8443` in the `server` line for your private cluster.

With the above, as long as the SSH proxy connection remains active, you can use `kubectl` to access your private Kubernetes cluster. Close the SSH connection in the other terminal tab to stop proxying to the private API.

### Use Sshuttle to get a VPN-like Experience

The [sshuttle](https://sshuttle.readthedocs.io/en/stable/) tool uses NAT redirect firewall rules to proxy access to a network over a bastion. This is useful to connect to multiple ports on multiple hosts without maintaining a lot of SSH forwarding.

The bastion already has Python installed, which sshuttle requires to be on the bastion. Once you have [installed sshuttle](https://sshuttle.readthedocs.io/en/stable/installation.html) on your workstation, use the following to redirect access to your VPC CIDR over the bastion - replacing `bastion.domain.com` with your bastion hostname, and `172.20.0.0/16` with your VPC CIDR:

```
sshuttle -r ubuntu@bastion.domain.com 172.20.0.0/16
```

You can now access your private Kubernetes API using the internal API hostname in the KubeConfig, and SSH directly to Kubernetes nodes without any proxy configuration defined in your `ssh_config` file.

Press CTRL-c to kill sshuttle when you are done with the proxy. There are many useful sshuttle command-line options, such as running in the background, and specifying the CIDR to redirect in a file.


[CloudWatch Logs Agent]: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html

## Using The Terraform Module

See the file [example-usage](./example-usage) for an example of how to use this module. Below are the available module inputs:

### Required Inputs

The following input variables are required:

#### infrastructure\_bucket

Description: An S3 bucket to store data that should persist on the bastion when it is recycled by the Auto Scaling Group, such as SSH host keys. This can be set in the environment via `TF_VAR_infrastructure_bucket`

Type: `string`

#### route53\_zone\_id

Description: ID of the ROute53 zone for the bastion to add its host record.

Type: `string`

#### ssh\_public\_key\_file

Description: The path to an existing SSH public key file, that will be used to create an AWS SSH Key Pair.

Type: `string`

#### unattended\_upgrade\_email\_recipient

Description: An email address where unattended upgrade errors should be emailed. THis sets the option in /etc/apt/apt.conf.d/50unattended-upgrades

Type: `string`

#### vpc\_id

Description: The VPC ID where the bastion and its security group will be created. This must match subnet IDs specified in the `vpc_subnet_ids` input.

Type: `string`

#### vpc\_subnet\_ids

Description: A list of subnet IDs where the Auto Scaling Group can place the bastion.

Type: `list`

### Optional Inputs

The following input variables are optional (have default values):

#### bastion\_name

Description: The name of the bastion EC2 instance, DNS hostname, CloudWatch Log Group, and the name prefix for other related resources.

Type: `string`

Default: `"ro-bastion"`

#### infrastructure\_bucket\_bastion\_key

Description: The key; sub-directory in $infrastructure_bucket where the bastion will be allowed to read and write. Do not specify a trailing slash. This allows sharing an S3 bucket among multiple invocations of this module.

Type: `string`

Default: `"bastion"`

#### instance\_type

Description: The EC2 instance type of the bastion.

Type: `string`

Default: `"t2.micro"`

#### log\_retention

Description: The number of days to retain logs in the CloudWatch Log Group.

Type: `string`

Default: `"60"`

#### remove\_root\_access

Description: Whether to remove root access from the ubuntu user. Set this to yes|true|1 to remove root access, or anything else to retain it.

Type: `string`

Default: `"true"`

#### ssh\_cidr\_blocks

Description: A list of CIDRs allowed to SSH to the bastion.

Type: `list`

Default:

```json
[
  "0.0.0.0/0"
]
```

#### unattended\_upgrade\_additional\_configs

Description: Additional configuration lines to add to /etc/apt/apt.conf.d/50unattended-upgrades

Type: `string`

Default: `""`

#### unattended\_upgrade\_reboot\_time

Description: The time that the bastion should reboot, when necessary, after an an unattended upgrade. This sets the option in /etc/apt/apt.conf.d/50unattended-upgrades

Type: `string`

Default: `"21:30"`


## Contributing

Thank you for your interest in improving this module. Please see [contributing](./CONTRIBUTING.md) for additional information.
