## Future To-do Items

* Perhaps break this ReadMe out into separate documents to make things more readable.
* Implement the same thing in Google Cloud.
* If the preferred usage pattern turns out to be SSH forwarding instead of sshuttle:
	* Add automation around modifying SSH config and KubeConfig to support using the bastion out of the box.
	* Explore managing the setup / tear-down of SSH forwarding in Pentagon Workstation (exiting the sub shell tears down the SSH fowrard).
	