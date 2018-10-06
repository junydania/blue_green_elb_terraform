#!/usr/bin/env bash

set -euxo pipefail

function describe_load_balancer()
{
    cd terraform;

    load_balancer_name=$(terraform output blue_green_elb_name);

    echo "$(aws elbv2 describe-load-balancers --names "$load_balancer_name")";
}

describe_load_balancer