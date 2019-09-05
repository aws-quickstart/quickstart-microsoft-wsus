# quickstart-microsoft-wsus
## Windows Server Update Services on the AWS Cloud


This Quick Start deploys a highly available Windows Server Update Services (WSUS) environment in the AWS Cloud.

WSUS acts as an organization's repository for Microsoft updates. Updates for Microsoft products (Windows server, Windows workstation operating systems, Office, etc.) are stored in the WSUS repository, and organization IT staff are able to approve or decline updates for distinct groups of servers and workstations.

This Quick Start deploys two WSUS servers behind an elastic load balancer. The servers share a SQL database and use a replicated DFS share for storing update files.

You can also use the AWS CloudFormation templates as a starting point for your own implementation.

For architectural details, best practices, step-by-step instructions, and customization options, see the 
deployment guide.

To post feedback, submit feature ideas, or report bugs, use the **Issues** section of this GitHub repo.
If you'd like to submit code for this Quick Start, please review the [AWS Quick Start Contributor's Kit](https://aws-quickstart.github.io/). 
