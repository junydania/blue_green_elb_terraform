# Blue/Green deploys using AWS Elastic Load Balancer

This is a simple Terraform provision script that creates some AWS infrastructure
consisting primarily of Elastic Load Balancer and a couple EC2 instances. This
is a proof of concept for using ELB as a way to do blue/green deployments.

**PLEASE NOTE:** Running Terraform will provision real resources in your AWS
account, and may incur costs to you as the account holder.

**DO NOT RUN THIS IN A SHARED AWS ACCOUNT OR ENVIRONMENT.** It provides no
protections against corrupting or otherwise damaging existing infrastructure. 

## Getting Started

<ol>
<li>Install <a href="https://www.terraform.io/downloads.html">Terraform</a></li>

<li>Set your AWS credentials in your environment:

```bash
export AWS_ACCESS_KEY_ID=your-access-key-id-here
export AWS_SECRET_ACCESS_KEY=your-secret-access-key-here
```
</li>

<li>Run <code>./up.sh</code></li>

<li>Be sure to supply valid filepaths to real public and private SSH keypairs that you want to use to SSH into the EC2 instances that will be created for you. This is necessary for the first provision,and for future access. If you are just trying this out, <code>~/.ssh/id_rsa</code> and <code>~/.ssh/id_rsa.pub</code> are probably fine in the short term.</li>
</ol>

## Tearing Down When Done

After you have explored this demo, be sure to destroy any residual Terraform
resources you have created to avoid being billed for them. To do this, run the
provided bash script, which should destroy only the Terraform infrastructure you
provisioned in the `up.sh` script:

```bash
./down.sh
``` 
