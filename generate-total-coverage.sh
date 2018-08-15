#!/usr/bin/env bash

set -eo pipefail

function clrd() {
    # 31 = red
    # 32 = green
    # 33 = yellow
    echo -e "\033[${3:-0};$2m$1\033[0m"
}

function ensure_not_empty {
    local readonly arg_name="$1"
    local readonly arg_value="$2"

    if [[ -z "${arg_value}" ]]; then
        echo "ERROR: The value for '${arg_name}' cannot be empty"
        exit 1
    fi
}

function run_script {
    local clover_file="$(pwd)/clover.xml"
    local output_file="$(pwd)/coverage"
    local commit_sha
    local commit_file="$(pwd)/current_sha"

    while [[ $# > 0 ]]; do
        local key="$1"

        case "$key" in
            --clover)
                clover_file="$2" ; shift
                ;;
            --output)
                output_file="$2" ; shift
                ;;
            --commit)
                commit_sha="$2" ; shift
                ;;
            --commit-file)
                commit_file="$2" ; shift
                ;;
            *)
                echo "ERROR: Unrecognized argument: $key"
                exit 1
                ;;
        esac

        shift
    done

    ensure_not_empty "--clover"         "$clover_file"
    ensure_not_empty "--output"         "$output_file"
    ensure_not_empty "--commit"         "$commit_sha"
    ensure_not_empty "--commit-file"    "$commit_file"

    echo -n "Clover XML input file: ${clover_file}"
    clrd " -- customize with [--clover <value>]" 33

    echo -n "Output file: ${output_file}"
    clrd " -- customize with [--output <value>]" 33
    echo

    coverage_percent=$(./generate-total-coverage.php "${clover_file}")
    echo "${coverage_percent}" >> ${output_file}
    echo "${commit_sha}"       >> ${commit_file}

    echo "Current code coverage: ${coverage_percent}"

    echo -n "Current SHA: ${commit_sha}"
    clrd " -- customize with [--commit <value>]" 33

    echo -n "Current SHA written to: ${commit_file}"
    clrd " -- customize with [--commit-file <value>]" 33
    echo
}

run_script $@
exit 0
