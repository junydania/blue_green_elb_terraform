#!/usr/bin/env bash

set -euo pipefail

function switch()
{
    current_target_group_arn=$(bash ./get-current-target-group.sh);
    green_target_group_arn=$(bash ./get-green-target-group.sh);
    blue_target_group_arn=$(bash ./get-blue-target-group.sh);
    listener_arn=$(bash ./get-listener-arn.sh);

    if [ "$current_target_group_arn" = "$green_target_group_arn" ]; then
        active_target_group="green";
        new_target_group="blue";
        new_target_group_arn="$blue_target_group_arn";
    elif [ "$current_target_group_arn" = "$blue_target_group_arn" ]; then
        active_target_group="blue";
        new_target_group="green";
        new_target_group_arn="$green_target_group_arn";
    else
        echo "Unable to determine the target group! Exiting."
        exit 1;
    fi

    echo "
The $active_target_group group is active! Switching to the $new_target_group group.
Current target group: $current_target_group_arn
Green target group: $green_target_group_arn
Blue target group: $blue_target_group_arn
Listener: $listener_arn
    ";

    aws elbv2 modify-listener \
        --listener-arn $listener_arn \
        --default-actions Type=forward,TargetGroupArn=$new_target_group_arn
}

switch