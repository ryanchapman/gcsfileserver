#!/bin/bash -

TRUE=0
FALSE=1

BOLD="$(tput bold)"
CLR="$(tput sgr0)"
RED="$(tput setaf 1 0)"
GREEN="$(tput setaf 10 0)"
CYAN="$(tput setaf 14 0)"

function _run
{
    if [[ $1 == fatal ]]; then
        errors_fatal=$TRUE
    else
        errors_fatal=$FALSE
    fi
    shift
    logit "${BOLD}$*${CLR}"
    eval "$*"
    rc=$?
    if [[ $rc != 0 ]]; then
        msg="${BOLD}${RED}$*${CLR}${RED} returned $rc${CLR}"
        if [[ $errors_fatal == $FALSE ]]; then
            msg+=" (error ignored)"
        fi
    else
        msg="${BOLD}${GREEN}$*${CLR}${GREEN} returned $rc${CLR}"
    fi
    logit "${BOLD}$msg${CLR}"
    # fail hard and fast
    if [[ $rc != 0 && $errors_fatal == $TRUE ]]; then
        pwd
        exit 1
    fi
    return $rc
}

function logit
{
    if [[ "${1}" == "FATAL" ]]; then
        fatal="FATAL"
        shift
    fi
    echo -n "$(date '+%b %d %H:%M:%S.%N %Z') $(basename -- $0)[$$]: "
    if [[ "${fatal}" == "FATAL" ]]; then echo -n "${RED}${fatal} "; fi
    echo "$*"
    if [[ "${fatal}" == "FATAL" ]]; then echo -n "${CLR}"; exit 1; fi
}

function run
{
    _run fatal $*
}

function run_ignerr
{
    _run warn $*
}

function deploy
{
    local args=""
    local project="$1"
    if [[ "${project}" != "" ]]; then
        args+="--project=${project}"
    fi
    logit "Deploying application to Google App Engine"
    run "gcloud app deploy --stop-previous-version --quiet ${args}"
    logit "Deploying application to Google App Engine: done"
}

function server
{
    logit "Starting local development server on port 8080"
    # Sometimes you need to run `go get` in the App Engine root
    #run "python /Users/rchapman/google-cloud-sdk/platform/google_appengine/goapp serve
    #GOPATH=/Users/$(id -un)/google-cloud-sdk/platform/google_appengine/gopath go get
    # Get go dependencies into appengine GOROOT
    #GOPATH=${sdk_dir}/platform/google_appengine/gopath go get
    run "dev_appserver.py ."
    logit "Starting local development server on port 8080: done"
}

function usage
{
    echo "usage: $(basename $0) <command> [arguments]"
    echo
    echo "Commands:"
    echo
    echo "    server            Run local server on port 8080"
    echo "    deploy [project]  Deploy to app engine.  If project is not specified, uses the default project"
    echo '                      (seen with `gcloud config get-value project`)'
    echo
}

#################################
# main
#################################

function main () {
    if [[ "${1}" =~ ^- ]]; then   # if someone passses in an arg like -h, -q, then show usage
      usage
      exit 1
    fi
    func_to_exec=${1:-server}
    type ${func_to_exec} 2>&1 | grep -q 'function' >&/dev/null || {
        logit "$(basename $0): ERROR: function '${func_to_exec}' not found."
        exit 1
    }

    shift
    ${func_to_exec} $*
    echo
}

main $*
