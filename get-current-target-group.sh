#!/usr/bin/env bash

set -euo pipefail

function get_current_target_group()
{
    cd terraform;

    load_balancer_arn=$(terraform output blue_green_elb_arn);

    echo $(
        aws elbv2 describe-listeners --load-balancer-arn "$load_balancer_arn" \
            | jq -r '.Listeners[0].DefaultActions[0].TargetGroupArn'
    );
}

get_current_target_group