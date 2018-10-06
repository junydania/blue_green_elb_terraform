#!/usr/bin/env bash

set -euo pipefail

function get_green_target_group()
{
    cd terraform;

    green_target_group_arn=$(terraform output green_target_group_arn);

    echo $green_target_group_arn;
}

get_green_target_group