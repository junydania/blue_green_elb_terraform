# Blue/Green deploys using AWS Elastic Load Balancer

This is a simple Terraform provision script that creates some AWS infrastructure
consisting primarily of Elastic Load Balancer and a couple EC2 instances. This
is a proof of concept for using ELB as a way to do [blue/green deployments](https://martinfowler.com/bliki/BlueGreenDeployment.html).

_[Read more about how this approach solves the blue/green deployment problem.](#specifics)_

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
<li>Make sure you have an RSA public/private keypair for SSH living at `~/.ssh/id_rsa` (private), and `~/.ssh/id_rsa.pub` (public). This keypair will be used by Ansible to provision the hosts.</li>
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

## The Blue/Green Deployment Pattern

The [blue/green deployment pattern](https://martinfowler.com/bliki/BlueGreenDeployment.html)
is a strategy for performing rapid, near-zero-downtime deployments of new code
to production, while still providing ample opportunity to roll back to a prior
state of the codebase if the error rate suddenly escalates after deployment.

In the era of high-concurrency many-user applications that are distributed and
in use across many timezones and regions, doing deployments at 3AM on a Saturday
offers no guarantee that SLAs will not be broken.

To counter this, the blue/green deployment strategy articulates an approach that
depends upon the "next" version of the application to be up, running, and ready
to receive a stampede of new network requests. When ready, the team can then
"throw the switch" using some kind of traffic redirection tool, so that the "old"
application stops receiving requests, and the "new application" instantly begins
to receive traffic.

## Specifics

This approach is built from an Elastic Load Balancer configured with two Target
Groups, one containing a "blue" application, and one containing a "green" app.
Each target group is essentially identical. Each group contains a single EC2
instance, consisting of Nginx running on Ubuntu 16.04, serving a static HTML
page that shows which "color" is currently active.

Terraform is used to stamp out the initial infrastructure. Ansible is then used
to actually provision the EC2 instances with Nginx and their static sites.
Initially, the "green" half of the fleet is in "active" state.

### Atomicity for the Win

This specific implementation leverages the [AWS Elastic Load Balancer's](https://aws.amazon.com/elasticloadbalancing/features/#Details_for_Elastic_Load_Balancing_Products)
ability to be updated using a single API call (in our case we use the AWS CLI
tool to do the legwork). The update made to switch the traffic from "blue" to
"green" (and back) is only one single HTTP request, which updates the ELB's
[Listener's](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-listeners.html)
current [Target Group](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-target-groups.html)
to point to a different group of hosts.

The fact that traffic can be redirected using a single, atomic API request to
AWS, without needing to manage complex state on the application servers or their
dependencies themselves, is a huge benefit:
- ELB is designed to handle massive amounts of traffic
- Unlike using DNS for traffic redirection, no host-level caching or long TTLs add latency
- ...so fewer users hitting stale hosts after deploys
- Easy to switch back to the other target group if something goes wrong (just one more single API call)
- Separates the process of provisioning and configuring EC2s from the act of deploying them to production
- AWS acts as single source of truth about which fleet of EC2s is "active", making configuration and re-provisioning far simpler
- Just less state management all around

While this demo only provisions two EC2 instances (one serving a static HTML page
showing the "blue" state, and one serving a page with the "green" state), it is
easy to imagine that instead of a simple static site served using Nginx, a big
and complex web application with many moving parts might be the end target of
this traffic. In fact, many use ELB in combination with auto-scaling groups of
many application instances to rapidly redirect traffic to a large fleet of
waiting EC2s (or other VMs, or even containers) idly waiting for their first
requests. 