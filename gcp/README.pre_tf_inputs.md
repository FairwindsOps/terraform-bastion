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
