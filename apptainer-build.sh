#!/bin/bash


usage() {
    echo \
"Build an Apptainer image
Usage:
  apptainer-build.sh [local options...] <IMAGE PATH> <BUILD SPEC>
Examples:
  apptainer-build.sh output.sif test_alpine.def"
    exit 1
}

if [[ -z "$@" ]]; then
    usage
fi


positional_args=()
opts=()

parse() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --?*)
                case $1 in 
                    -B|\
                    --bind|\
                    --build-arg|\
                    --build-arg-file|\
                    --docker-host|\
                    --library|\
                    --mount|\
                    --pem-path|\
                    --section)
                        opts+=("$1")
                        shift
                        if [[ $1 != -* && $1 != "" ]]; then
                            opts+=("$1")
                            shift
                        fi
                        ;;
                    --disable-cache|\
                    --docker-login|\
                    -e|\
                    --encrypt|\
                    -f|\
                    --fakeroot|\
                    --fix-perms|\
                    -F|\
                    --force|\
                    -h|\
                    --json|\
                    --no-cleanup|\
                    --no-https|\
                    -T|\
                    --notest|\
                    --nv|\
                    --nvccli|\
                    --passphrase|\
                    --rocm|\
                    -s|\
                    --sandbox|\
                    -u|\
                    --update|\
                    --userns|\
                    --warn-unused-build-args|\
                    --writable-tmpfs)
                        opts+=("$1")
                        shift
                        ;; 
                    --help)
                        apptainer-build-help
                        exit 0
                        ;;
                esac
                ;;
            *)
                positional_args+=("$1")
                shift
                ;;
        esac
    done
}

apptainer-build() {
    if [[ -n "$1" ]]; then
        echo $1
        touch $1
    fi
    podman run --rm --mount type=bind,src=$(pwd),dst=/work,ro=true \
        --mount type=bind,src=$(pwd)/$1,dst=/work/$1,ro=false \
        burooo/apptainer build $2
}

apptainer-build-help() {
    podman run --rm burooo/apptainer build --help
}

all_opts=$@
parse $@

out_file=${positional_args[0]}
def_file=${positional_args[1]}

IFS=' '
apptainer-build $out_file "${all_opts[*]}"

