# quickstart-microsoft-wsus
## Windows Server Update Services (WSUS) on AWS

This Quick Start deploys a Windows Server Update Services (WSUS) endpoint for downloading and managing updates on the Amazon Web Services (AWS) Cloud. This Quick Start is for system administrators and IT engineers who need to use WSUS as the endpoint point where Windows servers and other Microsoft applications are authorized to acquire updates.

WSUS is a server role included with Windows Server at no additional cost. It can download required updates and patches from the internet and act as an internally managed proxy server. WSUS can also manage clients, including other Windows servers, by defining policies that approve or decline updates and patches, and report compliance status of clients.

You can use the AWS CloudFormation templates included with the Quick Start to deploy WSUS in your AWS account in about 30 minutes. The Quick Start automates the following:

- Deploying WSUS into a new VPC
- Deploying WSUS into an existing VPC

![Quick Start architecture for Windows Server Update Services on the AWS Cloud](https://d0.awsstatic.com/partner-network/QuickStart/datasheets/wsus-on-the-aws-cloud-architecture.png)

For architectural details, best practices, step-by-step instructions, and customization options, see the [deployment guide](https://fwd.aws/KkYwn).

To post feedback, submit feature ideas, or report bugs, use the **Issues** section of this GitHub repo. If you'd like to submit code for this Quick Start, please review the [AWS Quick Start Contributor's Kit](https://aws-quickstart.github.io/).
