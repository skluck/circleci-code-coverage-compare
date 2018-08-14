#!/usr/bin/env bash

set -eo pipefail

current_coverage="$1"
head_coverage="${2:-90}"
increment="${3:-1}"

function clrd() {
    # 31 = red
    # 32 = green
    # 33 = yellow
    echo -e "\033[${3:-0};$2m$1\033[0m"
}

if [ -z "${current_coverage}" ] ; then
    clrd "ERROR: Current coverage must be provided" 31
    echo

    echo "Usage: $0 <current_coverage> [<coverage_of_target_branch>] [<minimum coverage increase>]"
    exit 1
fi

clrd "Mainline branch test coverage: ${head_coverage}%" 33
clrd "Required increase in coverage: ${increment}%" 33

echo
clrd "Test coverage of task branch: ${current_coverage}%" 33
echo

expected=$(echo "${head_coverage} + ${increment}" | bc)
comparison=$(echo "${current_coverage} ${expected}" | awk '{print ($1 > $2)}')

if [ ${comparison} == 1 ] ; then
    echo -n "Total code coverage is ${current_coverage}% which is"
    clrd " above the accepted ${expected}%" 32
    exit 1

else
    echo -n "Total code coverage is ${current_coverage}% which is"
    clrd " below the accepted ${expected}%" 31
fi
