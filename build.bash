#!/usr/bin/env bash
# -*- coding: utf-8 -*-

declare -A build_type_map=(
    ["release"]="-DCMAKE_BUILD_TYPE=Release"
    ["debug"]="-DCMAKE_BUILD_TYPE=Debug"
)

setup() {
    SCRIPTPATH=$(realpath "${BASH_SOURCE[0]}")
    SCRIPTDIR=$(dirname "$SCRIPTPATH")
    SCRIPTNAME=$(basename "$SCRIPTPATH")
    NPROC=$(nproc --ignore=1)
    BUILD_DIR="${SCRIPTDIR}/build"
    SRC_DIR="${SCRIPTDIR}/src"
    BUILD_TYPE="${build_type_map[release]}"
    BUILD_TYPE_SET=0
    BUILD_DEFINES=""
    BUILD_EXTRAS=""
    VERBOSE_FLAG="--quiet"
    PATH_TO_CLEAN=""
    SHOULD_CLEAN=0
}

setup_build_dir() {
    BUILD_DIR="$2"
    return 1
}

# $1 = path to directory clean
setup_clean() {
    PATH_TO_CLEAN="$1"
    SHOULD_CLEAN=1
}

handle_if_should_clean() {
    if [[ "$SHOULD_CLEAN" == 1 ]]; then
        if [[ -z "$PATH_TO_CLEAN" ]]; then
            rm -rf "$BUILD_DIR"
        else
            rm -rf "$PATH_TO_CLEAN"
        fi
    fi
}

# $1 = Build Types: [debug or release]
validate_build_type() {
    local -r build_type="$1"
    if [[ "$BUILD_TYPE_SET" == 1 ]]; then
        echo "[ERROR] Cannot use set build type twice"
        exit 1
    else
        BUILD_TYPE_SET=1
    fi

    BUILD_TYPE="${build_type_map[$build_type]}"
    return 1
}

find_built_target() {
    # take executable with longer path (ie the actual exe and not just the path)
    find "$BUILD_DIR/bin" -executable | sort -r | head -n 1
}

run_cmake() {
    mkdir -p "$BUILD_DIR"
    cd -- "${BUILD_DIR}" || exit
    cmake "$BUILD_TYPE" "$BUILD_DEFINES" "$BUILD_EXTRAS" "${SRC_DIR}"
    cmake \
        --build "$BUILD_DIR" \
        --parallel "$NPROC" \
        --target all \
        -- "$VERBOSE_FLAG"

    echo "Built target: $(find_built_target)"
}

print_usage() {
cat << EOF
=========================================================================================================================
Usage: $SCRIPTNAME (aka $SCRIPTPATH)
=========================================================================================================================
Helper utility to build everything in this repo
=========================================================================================================================
How to use:
To Start: $SCRIPTNAME [flags]
=========================================================================================================================
Available Flags:
-c | --clean: Removes the existing build directory (allows building from scratch)
-v | --verbose: Print all build info
-j | --num-proc: Number of cores to use when building (tip: check how many you have available with 'nproc').
    Default is your number of cores-1 to prevent soft-locking during build (=$NPROC)
-b | --build-dir: The path the directory where building will occur. Binary will be located in at build_dir/bin
-r | --release: Build with release optimization (mutually exclusive with --debug)
-d | --debug: Build in debug mode without optimization (mutually exclusive with --release)
-h | --help: This message
=========================================================================================================================
EOF
}

parse_cli_opts() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -c | --clean )
                setup_clean "$2"
                ;;
            -v | --verbose )
                VERBOSE_FLAG+=""
                shift 1
                ;;
            -j | --num-proc )
                NPROC="$1"
                shift 1
                ;;
            -b | --build-dir )
                setup_build_dir "$2"
                shift "$?"
                ;;
            -r | --release )
                validate_build_type "release"
                shift "$?"
                ;;
            -d | --debug )
                validate_build_type "debug"
                shift "$?"
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
    handle_if_should_clean
    run_cmake
}
main "$@"
