# Blue/Green deploys using AWS Elastic Load Balancer

This is a simple Terraform provision script that creates some AWS infrastructure
consisting primarily of Elastic Load Balancer and a couple EC2 instances. This
is a proof of concept for using ELB as a way to do blue/green deployments.

## Getting Started

1. Install [Terraform](https://www.terraform.io/downloads.html)
2. Set your AWS credentials in our environment, [or follow Terraform's instructions for other methods](https://www.terraform.io/docs/providers/aws/)
3. Run `terraform apply`
4. Be sure to supply valid filepaths to real public and private SSH keypairs that you want to use to SSH into the EC2 instances that will be created for you. This is necessary for the first provision,and for future access. If you are just trying this out, `~/.ssh/id_rsa` and `~/.ssh/id_rsa.pub` are probably fine in the short term.
