#!/usr/bin/env bash

set -euo pipefail

function get_blue_target_group()
{
    cd ./terraform;

    terraform output blue_target_group_arn
}
