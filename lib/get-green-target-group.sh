#!/usr/bin/env bash

set -euo pipefail

function get_green_target_group()
{
    cd ./terraform;

    terraform output green_target_group_arn;
}
