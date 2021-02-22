# Terraform GCP Bastion Module

This module manages a Google Cloud bastion compute instance and its regional Auto Scaling Group, service account, SSH firewall rule, and SSH access. The Auto Scaling Group will recreate the bastion if there is an issue with the compute instance or the availability zone where it is running.

The startup script assumes the Ubuntu operating system, which is configured as follows:

* Packages are updated, and the bastion is rebooted if required.
* If SSH hostkeys are present in the configurable GCS bucket and path, they are copied to the bastion to retain its previous SSH identity. If there are no host keys in GCS, the current keys are copied there.
* The Google Accounts daemon is disabled so that SSH access is managed exclusively by this module. This disables the ability to use `gcloud compute ssh ...` to SSH to the bastion.
* The [Stackdriver Logging agent][] is installed and configured to ship logs from these files:
	* `/var/log/syslog`
	* `/var/log/auth.log`
* A host record, named using the `bastion_name` module input,  is added to a configurable Google DNS managed DNS zone for the current public IP address of the bastion. This happens via a script configured to run each time the bastion boots.
* Automatic updates are configured, using a configurable time to reboot, and the email address to receive errors.
* By default sudo access is removed from the ubuntu user unless the `remove_root_access` input is set to "false."
* Additional startup script commands can be executed, for one-off configuration not included in this module.
* Additional users can be created and populated with their own `authorized_keys` file.

## Using The Bastion
### SSH Access to Kubernetes Nodes

To proxy SSH connections to Kubernetes nodes through the bastion, add configuration like the following to the top of the `ssh_config` file. Replace the following information with your own values:

* `domain.com` with the same **domain name** that matches the Google DNS zone name in the instance of the bastion Terraform module. This is the domain name where the bastions host record will have been created during boot.
* `/path/to/ssh/private/key` with the path to your SSH private key file.
* `172.20.*.*` with the network CIDR used by Kubernetes node compute instances.

```
# Define options to be used when connecting to the bastion.
host bastion.domain.com
  IdentityFile /path/to/ssh/private/key
  IdentitiesOnly yes
  User ubuntu

# Use the bastion to proxy SSH connections to IPs in the Kubernetes node network
# You can also add a DNS wildcard to the end of the next line
# if you use DNS resolution to access Kubernetes nodes.
host 172.20.*.*
  ProxyCommand ssh -i /path/to/ssh/private/key ubuntu@bastion.domain.com -W %h:%p
```

You can now use `gcloud compute ssh --internal-ip your_gke_node_hostname` to SSH directly to IP addresses within `172.20.0.0/16`, and your connection will be proxied through the bastion.

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

The bastion already has Python installed, which sshuttle requires to be on the bastion. Once you have [installed sshuttle](https://sshuttle.readthedocs.io/en/stable/installation.html) on your workstation, use the following to redirect access to your network CIDR over the bastion - replacing `bastion.domain.com` with your bastion hostname, and `172.20.0.0/16` with your network CIDR:

```
sshuttle -r ubuntu@bastion.domain.com 172.20.0.0/16
```

You can now access your private Kubernetes API using the internal API hostname in the KubeConfig, and SSH directly to Kubernetes nodes without any proxy configuration defined in your `ssh_config` file.

Press CTRL-c to kill sshuttle when you are done with the proxy. There are many useful sshuttle command-line options, such as running in the background, and specifying the CIDR to redirect in a file.


## Using The Terraform Module

See the file [example-usage](./example-usage) for an example of how to use this module. Below are the available module inputs:

### Required Inputs

The following input variables are required:

#### availability\_zones

Description: The availability zones within $region where the Auto Scaling Group can place the bastion.

Type: `list`

#### dns\_zone\_name

Description: The name of the Google DNS zone for the bastion to add its host record. Specify the name of the managed zone, not the domain name.

Type: `string`

#### infrastructure\_bucket

Description: An GCS bucket to store data that should persist on the bastion when it is recycled by the Auto Scaling Group, such as SSH host keys. This can be set in the environment via `TF\_VAR\_infrastructure\_bucket`

Type: `string`

#### network\_name

Description: The name of the network where the bastion SSH firewall rule will be created. This network is the parent of $subnetwork

Type: `string`

#### region

Description: The region where the bastion should be provisioned. This is a required input for the google\_compute\_region\_instance\_group\_manager Terraform resource, and is not inherited from the provider.

Type: `string`

#### ssh\_public\_key\_file

Description: The path to an existing SSH public key file, that will be used with the `ssh-keys` GCP metadata to allow SSH access.

Type: `string`

#### subnetwork\_name

Description: The name of the existing subnetwork where the bastion will be created.

Type: `string`

#### unattended\_upgrade\_email\_recipient

Description: An email address where unattended upgrade errors should be emailed. THis sets the option in /etc/apt/apt.conf.d/50unattended-upgrades

Type: `string`

### Optional Inputs

The following input variables are optional (have default values):

#### additional\_external\_users

Description: Additional users to be created on the bastion. Works the same as additional\_users, but adds users via a separate systemd unit file. Specify users as a list of maps. See an example in the `example-usage` file. Required map keys are `login` \(user name\) and `authorized\_keys`. Optional map keys are `gecos` \(full name\), `supplemental\_groups` \(comma-separated\), and `shell`. The authorized\_keys will be output to ~/.ssh/authorized\_keys using printf - multiple keys can be specified by including \n in the string.

Type: `list`

Default:

```json
[]
```

#### additional\_setup\_script

Description: Content to be appended to the setup script, which is run the first time the bastion compute instance boots.

Type: `string`

Default: `""`

#### additional\_users

Description: Additional users to be created on the bastion. Specify users as a list of maps. See an example in the `example-usage` file. Required map keys are `login` \(user name\) and `authorized\_keys`. Optional map keys are `gecos` \(full name\), `supplemental\_groups` \(comma-separated\), and `shell`. The authorized\_keys will be output to ~/.ssh/authorized\_keys using printf - multiple keys can be specified by including \n in the string.

Type: `list`

Default:

```json
[]
```

#### bastion\_name

Description: The name of the bastion compute instance, DNS hostname, IAM service account, and the name prefix for other related resources.

Type: `string`

Default: `"ro-bastion"`

#### image\_family

Description: The family for the compute image. This module has assumptions about the OS being Ubuntu.

Type: `string`

Default: `"ubuntu-1804-lts"`

#### image\_project

Description: The project of the compute image owner.

Type: `string`

Default: `"ubuntu-os-cloud"`

#### infrastructure\_bucket\_bastion\_key

Description: The key; sub-directory in $infrastructure\_bucket where the bastion will be allowed to read and write. Do not specify a trailing slash. This allows sharing a GCS bucket among multiple invocations of this module.

Type: `string`

Default: `"bastion"`

#### machine\_type

Description: The GCE machine type of the bastion.

Type: `string`

Default: `"n1-standard-1"`

#### remove\_root\_access

Description: Whether to remove root access from the ubuntu user. Set this to yes\|true\|1 to remove root access, or anything else to retain it.

Type: `string`

Default: `"true"`

#### ssh\_cidr\_blocks

Description: A list of CIDRs allowed to SSH to the bastion. Override the module default by specifying an empty list, \[\]

Type: `list(string)`

Default: `[ "0.0.0.0/0" ]`

#### unattended\_upgrade\_additional\_configs

Description: Additional configuration lines to add to /etc/apt/apt.conf.d/50unattended-upgrades

Type: `string`

Default: `""`

#### unattended\_upgrade\_reboot\_time

Description: The time that the bastion should reboot, when necessary, after an an unattended upgrade. This sets the option in /etc/apt/apt.conf.d/50unattended-upgrades

Type: `string`

Default: `"21:30"`


## Additional Design Considerations

The [design document](../DESIGN.md) describes the goals and vision for this project. 

## Contributing

Thank you for your interest in improving this module. Please see [contributing](../CONTRIBUTING.md) for additional information.


[Stackdriver Logging agent]: https://cloud.google.com/logging/docs/agent/installation
