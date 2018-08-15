#!/usr/bin/env bash

set -eo pipefail

function clrd() {
    # 31 = red
    # 32 = green
    # 33 = yellow
    echo -e "\033[${3:-0};$2m$1\033[0m"
}

function ensure_is_installed {
    local readonly name="$1"

    if [[ ! $(command -v ${name}) ]]; then
        clrd "ERROR: The binary '$name' is required by this script but is not installed or in the system's PATH." 31
        exit 1
    fi
}

function ensure_not_empty {
  local readonly arg_name="$1"
  local readonly arg_value="$2"

  if [[ -z "${arg_value}" ]]; then
    clrd "ERROR: The value for '${arg_name}' cannot be empty" 31
    exit 1
  fi
}

function compare_coverage {
    local readonly base_coverage="$1"
    local readonly current_coverage="$2"
    local readonly increment="$3"

    expected=$(echo "${base_coverage} + ${increment}" | bc)
    comparison=$(echo "${current_coverage} ${expected}" | awk '{print ($1 >= $2)}')

    if [ ${comparison} == 1 ] ; then
        echo -n "Total code coverage is ${current_coverage}% which is"
        clrd " above the accepted ${expected}%" 32

    else
        echo -n "Total code coverage is ${current_coverage}% which is"
        clrd " below the accepted ${expected}%" 31
        exit 1
    fi
}

function run_script {
    local base_branch="master"
    local current_branch

    local base_coverage="90"
    local current_coverage

    local required_increase="${REQUIRED_TEST_COVERAGE_INCREASE:-1}"

    while [[ $# > 0 ]]; do
        local key="$1"

        case "$key" in
            --base-branch)
                base_branch="$2" ; shift
                ;;
            --current-branch)
                current_branch="$2" ; shift
                ;;
            --base-coverage)
                base_coverage="$2" ; shift
                ;;
            --current-coverage)
                current_coverage="$2" ; shift
                ;;
            *)
                echo "ERROR: Unrecognized argument: $key"
                exit 1
                ;;
        esac

        shift
    done

    ensure_not_empty "--base-branch"        "$base_branch"
    ensure_not_empty "--current-branch"     "$current_branch"
    ensure_not_empty "--base-coverage"      "$base_coverage"
    ensure_not_empty "--current-coverage"   "$current_coverage"

    ensure_not_empty "\$REQUIRED_TEST_COVERAGE_INCREASE" "$required_increase"

    ensure_is_installed "awk"
    ensure_is_installed "bc"

    if [ "${base_branch}" == "${current_branch}" ] ; then
        echo "Running on base branch. Skipping unit test coverage comparison."
        exit 0
    fi

    echo -n "Required increase in coverage: ${required_increase}%"
    clrd " -- customize with \$REQUIRED_TEST_COVERAGE_INCREASE" 33
    echo

    clrd "Main branch test coverage: ${base_coverage}%" 33
    clrd "Test coverage of current branch: ${current_coverage}%" 33
    echo

    compare_coverage "${base_coverage}" "${current_coverage}" "${required_increase}"
}

run_script $@
exit 0
