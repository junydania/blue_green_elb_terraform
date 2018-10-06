# Blue/Green deploys using AWS Elastic Load Balancer

This is a simple Terraform provision script that creates some AWS infrastructure
consisting primarily of Elastic Load Balancer and a couple EC2 instances. This
is a proof of concept for using ELB as a way to do blue/green deployments.

The Terraform plan should define infrastructure that looks like this:

[![Terraform plan diagram](./graph.png)](https://cloudcraft.co/view/1c585bca-0562-4b11-8281-bd948044fd92?key=cQrA7McsgrYL_ajeG7SjUw)

**PLEASE NOTE:** Running Terraform will provision real resources in your AWS
account, and may incur costs to you as the account holder.

**DO NOT RUN THIS IN A SHARED AWS ACCOUNT OR ENVIRONMENT.** It provides no
protections against corrupting or otherwise damaging existing infrastructure. 

## Dependencies

In order to install and interact with this demo, you'll need the following
dependencies installed:

- [Terraform](https://www.terraform.io/downloads.html)
- [The AWS CLI tool](https://docs.aws.amazon.com/cli/latest/userguide/installing.html)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [jq](https://stedolan.github.io/jq/) 

## Getting Started

<ol>
<li>Set your AWS credentials in your environment:

```bash
export AWS_ACCESS_KEY_ID=your-access-key-id-here
export AWS_SECRET_ACCESS_KEY=your-secret-access-key-here
```
</li>

<li>Run <code>bin/up</code></li>
</ol>

## Changing from "green" to "blue"

When you visit the URL associated with the AWS Elastic Load Balancer created by
Terraform, you should see that the "green" EC2 instance is receiving traffic.

Now, run the command `bin/switch`. Reload the browser, and you should see that
the page now shows the "blue" EC2 instance is serving its page.

Run `bin/switch` again, and you should see the page go back to "green".

**Note:** It might take a few reloads to see the new content, but it should take
only a few seconds for AWS to start redirecting traffic to the new Target Group
after switching each time.

## Tearing Down When Done

After you have explored this demo, be sure to destroy any residual Terraform
resources you have created to avoid being billed for them. To do this, run the
provided bash script, which should destroy only the Terraform infrastructure you
provisioned in the `up` script:

```bash
bin/down
``` 
