Scenario


Company using azure to manage resources and another company using AWS to manage resources that need access to each others networks and resources. AWS architected framework may need to be considered. Only terraform should be used to achieve everything and Git and GitHub can be used for the code

Steps to be taken:

	• Create a Virtual network in azure and a VPC in AWS with an instance running in AWS and a virtual machine in azure.
	• Create a site-to-site VPN tunnel between these two networks
	• Able to ping an ec2 instance from a azure virtual machine
	• Use an azure active directory user to authenticate to an aws ec2 instance


