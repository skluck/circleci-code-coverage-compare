#!/usr/bin/env bash

set -eo pipefail

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
                input_file="$2" ; shift
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

    ensure_not_empty "--clover"         "$input"
    ensure_not_empty "--output"         "$output"
    ensure_not_empty "--commit"         "$commit_sha"
    ensure_not_empty "--commit-file"    "$commit_file"

    echo "Clover XML input file: ${clover_file} -- customize with the [--clover <value>]"
    echo "Output file: ${output_file} -- customize with the [--output <value>]"
    echo

    coverage_percent=$(php ./generate-total-coverage.php "${clover_file}")
    echo "${coverage_percent}" >> ${output_file}
    echo "${commit_sha}"       >> ${commit_file}

    echo "Current code coverage: ${coverage_percent}"
    echo "Current SHA written to: ${commit_file}"
    echo
}

run_script $@
exit 0
