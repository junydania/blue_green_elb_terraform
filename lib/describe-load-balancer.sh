#!/usr/bin/env bash

set -euo pipefail

function describe_load_balancer()
{
    cd ./terraform;

    load_balancer_name=$(terraform output blue_green_elb_name);

    aws elbv2 describe-load-balancers --names "$load_balancer_name";
}
