#!/usr/bin/env bash

set -euo pipefail

function get_listener_arn()
{
    cd ./terraform;

    load_balancer_arn=$(terraform output blue_green_elb_arn);

    aws elbv2 describe-listeners --load-balancer-arn "$load_balancer_arn" \
        | jq -r '.Listeners[0].ListenerArn'
}
