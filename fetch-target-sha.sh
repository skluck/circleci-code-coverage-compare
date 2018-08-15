#!/usr/bin/env bash

set -eo pipefail

trap remove_temp EXIT

function remove_temp {
    if [ -f "$(pwd)/jq" ] ; then
        rm -rf "$(pwd)/jq"
    fi

    if [ -f "$(pwd)/branch.txt" ] ; then
        rm -rf "$(pwd)/branch.txt"
    fi
}

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

function check_is_installed {
    local readonly name="$1"

    if [[ ! $(command -v ${name}) ]]; then
        echo -n "false"
    fi

    echo -n "true"
}

function ensure_not_empty {
  local readonly arg_name="$1"
  local readonly arg_value="$2"

  if [[ -z "${arg_value}" ]]; then
    clrd "ERROR: The value for '${arg_name}' cannot be empty" 31
    exit 1
  fi
}

function install_jq_linux {
    local readonly download_path="$1"
    local readonly release_url="https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64"

    curl -sSL -o "${download_path}" "${release_url}"
    chmod +x "${download_path}"
}

function ensure_jq {
    local readonly distro=$(uname -a | cut -d' ' -f1)
    if [ "${distro}" == "Linux" ] ; then
        ensure_is_installed "curl"

        if [ $(check_is_installed "jq") == true ] ; then
            echo "jq is installed!"
        else
            echo "jq not installed. Attempting to install..."
            install_jq_linux "$(pwd)/jq"
            export PATH=$PATH:$(pwd)
        fi

    elif [ "${distro}" == "Darwin" ] ; then
        ensure_is_installed "curl"
        ensure_is_installed "jq"

    else
        clrd "Could not detect operating system." 31
        exit 1
    fi
}

function download_sha {
    local readonly remote_url="$1"
    local readonly local_file="$2"

    curl -sSL -o "${local_file}" "${main_branch_url}"
    main_sha=$(cat "${local_file}" | jq -r '.commit.sha')

    echo $main_sha
}

function run_script {
    local github_url="api.github.com"
    local gh_user
    local gh_repo
    local main_branch="master"
    local current_branch
    local commit_file="$(pwd)/base_commit_sha"

    while [[ $# > 0 ]]; do
        local key="$1"

        case "$key" in
            --user)
                gh_user="$2" ; shift
                ;;
            --repo)
                gh_repo="$2" ; shift
                ;;
            --github)
                github_url="$2" ; shift
                ;;
            --base-branch)
                main_branch="$2" ; shift
                ;;
            --current-branch)
                current_branch="$2" ; shift
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

    ensure_not_empty "--github"         "$github_url"
    ensure_not_empty "--user"           "$gh_user"
    ensure_not_empty "--repo"           "$gh_repo"
    ensure_not_empty "--base-branch"    "$main_branch"

    ensure_not_empty "--current-branch" "$current_branch"
    ensure_not_empty "--commit-file"    "$commit_file"

    if [ "${github_url}" != "api.github.com" ] ; then
        github_url="${github_url}/api/v3"
    fi

    if [ "${main_branch}" == "${current_branch}" ] ; then
        echo "Running on base branch. Skipping unit test coverage comparison."
        touch ${commit_file}
        exit 0
    fi

    local main_branch_url="https://${github_url}/repos/${gh_user}/${gh_repo}/branches/${main_branch}"
    local local_file="$(pwd)/branch.txt"

    local base_sha=$(download_sha "${main_branch_url}" "${local_file}")

    echo "Base branch SHA: ${base_sha}"

    echo -n "Base branch SHA written to: ${commit_file}"
    clrd " -- customize with [--commit-file <value>]" 33
    echo

    echo "${base_sha}" >> ${commit_file}
}

run_script $@
exit 0
