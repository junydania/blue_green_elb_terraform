#!/usr/bin/env bash

set -euo pipefail

function get_blue_target_group()
{
    cd terraform;

    blue_target_group_arn=$(terraform output blue_target_group_arn);

    echo $blue_target_group_arn;
}

get_blue_target_group