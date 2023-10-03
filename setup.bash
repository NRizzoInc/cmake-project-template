#!/usr/bin/env bash
# -*- coding: utf-8 -*-

setup() {
    INSTALL_ALL=1 # default to installing everything
    INSTALL_LINUX_PKGS=0
}

install_linux() {
    echo "================ Running Linux Package Manager Script ================"
    sudo apt update
    sudo apt install -y \
        cmake \
        build-essential \
    echo "=============== Compelted Linux Package Manager Script ==============="
}

print_usage() {
cat << EOF
=========================================================================================================================
Usage: $SCRIPTNAME (aka $SCRIPTPATH)
=========================================================================================================================
Helper utility to setup everything in this
=========================================================================================================================
How to use:
To Start: $SCRIPTNAME [flags]
=========================================================================================================================
Available Flags:
-a | --install-all: (Default) If used, install everything (recommended for fresh installs)
-p | --linux-pkgs: Install all the required linux packages
-h | --help: This message
=========================================================================================================================
EOF
}

parse_cli_opts() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -a | --install-all )
                INSTALL_ALL=true
                break
                ;;
            -p | --linux-pkgs )
                INSTALL_LINUX_PKGS=true
                INSTALL_ALL=false
                break
                ;;
            -h | --help )
                print_usage
                exit 0
                ;;
            * )
                echo "... Unrecognized Command: $1"
                print_usage
                exit 1
                ;;
        esac
        shift
    done
}

main() {
    setup
    parse_cli_opts "$@"

    if [[ "$INSTALL_ALL" == 1 ]] || [[ "$INSTALL_LINUX_PKGS" == 1 ]]; then
        install_linux
    fi
}
main "$@"
