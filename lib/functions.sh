#!/usr/bin/env bash

set -euo pipefail

# shellcheck disable=SC1091
source ./lib/describe-load-balancer.sh;

# shellcheck disable=SC1091
source ./lib/get-blue-target-group.sh;

# shellcheck disable=SC1091
source ./lib/get-current-target-group.sh;

# shellcheck disable=SC1091
source ./lib/get-green-target-group.sh;

# shellcheck disable=SC1091
source ./lib/get-listener-arn.sh;
