#!/bin/bash
set -e
set -o pipefail

cmd=$(basename $0)

ARGS=$(getopt -o a::clht -l all::,clone,config,clear,help,test -n "${cmd}" -- "$@")
eval set -- "${ARGS}"

ROOT_PATH=$(
    cd "$(dirname "$0")"
    pwd
)

SCRIPT_PATH=$ROOT_PATH"/script"
CLONE_AND_CHECKOUT=${SCRIPT_PATH}/clone_and_checkout
LOTUS_GO_MOD=${SCRIPT_PATH}/lotus_go_mod
LOTUS_MAKEFILE=${SCRIPT_PATH}/lotus_makefile
RUST_MOD=${SCRIPT_PATH}/rust_mod
FFI_TEMPLATE=${SCRIPT_PATH}/ffi_template

# http_proxy https_proxy
ENV_LOG_DIR=$(cd `dirname $0`; pwd)
if [ -f $ENV_LOG_DIR/env_proxy ]; then
  source $ENV_LOG_DIR/env_proxy
else
  while [ ! -f $ENV_LOG_DIR/env_proxy ]
  do
    #lotus_proxy
    read -e -p '  please input https_proxy:' lotus_proxy
    #echo ' '
    echo "export http_proxy=$lotus_proxy" >> $ENV_LOG_DIR/env_proxy
    echo "export https_proxy=$lotus_proxy" >> $ENV_LOG_DIR/env_proxy
  done
  echo " "
fi
# tips
if [ -f $ENV_LOG_DIR/env_proxy ]; then
  source $ENV_LOG_DIR/env_proxy
fi
echo -e "\033[34m http_proxy=$http_proxy \033[0m"
echo -e "\033[34m https_proxy=$https_proxy \033[0m"

main() {
    while true; do
        case "${1}" in
        -a | --all)
            echo "builder building..."
            shift
            if [[ -n "${1}" ]]; then
                val_2k="${1}"
                if [ $val_2k = "2k" ]; then
                    all_2k
                elif [ $val_2k = "all" ]; then
                    all_full
                else
                    Usage
                fi
                shift
            else
                all
            fi
            exit 0
            ;;
        --clone)
            echo "builder clone"
            git_clone
            exit 0
            ;;
        -c | --config)
            echo "builder config"
            config
            exit 0
            ;;
        -l | --clear)
            echo "builder clear"
            clear
            exit 0
            ;;
        -t | --test)
            echo "builder test"
            just_for_test
            exit 0
            ;;
        -h | --help)
            Usage
            exit 0
            ;;
        --)
            shift
            break
            ;;
        *)
            Usage
            exit 0
            ;;
        esac
    done

    Usage
    exit 0
}

Usage() {
    echo "Usage:"${cmd}" options {-a,--all(2k,all) | --clone | -c,--config | -l,--clear | -t,--test | -h}"
}

all() {
    git_clone
    config
    build_lotus
}

all_2k() {
    git_clone
    config
    build_lotus 2k
}

all_full() {
    git_clone
    config
    build_lotus full
}

config() {
    cp -rf $ROOT_PATH/template/* $ROOT_PATH
}

clear() {
    rm -rf lotus
    rm -rf rust-filecoin-proofs-api
    rm -rf rust-fil-proofs
    rm -rf filecoin-ffi
    rm -rf go-state-types
    rm -rf bellman
    rm -rf go-paramfetch
    rm -rf sapling-crypto
    rm -rf specs-actors-v0.9.12
    rm -rf specs-actors-v2.0.1
    rm -rf bellperson

    rm -rf chain-validation
    rm -rf go-fil-markets
    rm -rf go-padreader
    rm -rf specs-storage
    rm -rf statediff
    rm -rf test-vectors
    rm -rf fil-sapling-crypto
    rm -rf chain-validation
    rm -rf neptune
    rm -rf phase2
}

git_clone() {
    # filecash/v0.9.0
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/lotus.git" lotus "2be429cff808ae21207785b8f7bc21f794e2852e"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/rust-filecoin-proofs-api.git" rust-filecoin-proofs-api "f704653ab77246e2982251d44136ca1c20b497ce"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/rust-fil-proofs.git" rust-fil-proofs "c8cfc7d2868ffbf05fb0dd0a7c2d6e68b2a06702"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-actors.git" specs-actors-v0.9.12 "2e5925f8069e5cff89233cbbb5b7817cb2a9fac8"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-actors.git" specs-actors-v2.0.1 "44acc9427990c392d6c6838d7d94bc74fcbdac9d"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/filecoin-ffi.git" filecoin-ffi "d47d97b2822c3dc190f8d2359a49410fef1ff5e8"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/go-state-types.git" go-state-types "046a62e50106d493dd110de078795c3d7f3d0d8e"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/bellman.git" bellperson "54854fa048ec508ebbdc7c06aa4360602612819b"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/go-paramfetch.git" go-paramfetch "829f513be2b5dacc424ef6be1762c39c7d81b420"

    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/chain-validation.git" chain-validation "40c22fe26eefba10b7bbb24bf8e742b2a0e2478c"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/go-fil-markets.git" go-fil-markets "v0.7.0"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/go-padreader.git" go-padreader "ed5fae088b20"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/specs-storage.git" specs-storage "ed2e5cd13796"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/statediff.git" statediff "v0.0.1"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/test-vectors" test-vectors "7471e2805fc3e459e4ee325775633e8ec76cb7c6"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/sapling-crypto.git" sapling-crypto "v0.6.3"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/neptune.git" neptune "v1.1.1"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/phase2.git" phase2 "v0.8.0"
}

check_yesorno() {
  unset yesorno
  while [ -z $yesorno ]
  do
    echo " "
    read -e -r -p "Are you sure set FFI_BUILD_FROM_SOURCE? [[Y]es/[N]o " input
    case $input in
      [yY][eE][sS]|[yY])
        echo -e "\033[34m Yes \033[0m"
        yesorno=1
        ;;

      [nN][oO]|[nN])
        echo -e "\033[34m No \033[0m"
        yesorno=0
        ;;

      *)
        echo -e "\033[31m Invalid input... \033[0m"
        ;;
    esac
  done
# return $yesorno
}

build_lotus() {
    cd filecoin-ffi
    make clean
    cd -

    check_yesorno
    if [ $yesorno -eq 1 ]; then
       _FFI_BUILD_FROM_SOURCE=1
    else
       _FFI_BUILD_FROM_SOURCE=0
    fi
    
    set +e
    result=$(grep -m 1 'vendor_id' /proc/cpuinfo | grep "Intel")
    if [[ "$result" != "" ]] ; then
       arch=intel
       export CGO_CFLAGS="-O -D__BLST_PORTABLE__" 
       export RUSTFLAGS="-C target-cpu=native -A dead_code"
    else
       arch=amd
    fi
    set -e
    
    cd lotus
    make clean
    if [ $_FFI_BUILD_FROM_SOURCE -eq 1 ]; then
        FBFS="FFI_BUILD_FROM_SOURCE=1"
    else
        FBFS="FFI_BUILD_FROM_SOURCE=0"
    fi
    BUILD_ENV=${BUILD_ENV}" "$FBFS
    echo make "$@" ${BUILD_ENV}
    make "$@" ${BUILD_ENV}
    cd -
}

main "$@"

