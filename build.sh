#!/bin/bash

set -e
set -o pipefail

cmd=$(basename $0)

unset _FFI_BUILD_FROM_SOURCE_INPUT
for arg in "$@"
do
  if [ "$arg" = "-y" ] || [ "$arg" = "--yes" ] ; then
     _FFI_BUILD_FROM_SOURCE_INPUT=1
  fi
done

ARGS=$(getopt -o a::cb::lhty -l all::,clone,config,build,clear,help,test,yes -n "${cmd}" -- "$@")
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
if [ -f $ENV_LOG_DIR/.env_proxy ]; then
  source $ENV_LOG_DIR/.env_proxy
else
  while [ ! -f $ENV_LOG_DIR/.env_proxy ]
  do
    #lotus_proxy
    read -e -p '  please input https_proxy:' lotus_proxy
    #echo ' '
    echo "export http_proxy=$lotus_proxy" >> $ENV_LOG_DIR/.env_proxy
    echo "export https_proxy=$lotus_proxy" >> $ENV_LOG_DIR/.env_proxy
  done
  echo " "
fi
# tips
if [ -f $ENV_LOG_DIR/.env_proxy ]; then
  source $ENV_LOG_DIR/.env_proxy
fi
if [ ! -d $TMPDIR ]; then
    mkdir $TMPDIR
elif [ ! -d $GOPATH ]; then
    mkdir $GOPATH
fi
echo -e "\033[34m http_proxy=$http_proxy \033[0m"
echo -e "\033[34m https_proxy=$https_proxy \033[0m"
echo ""

main() {
    while true; do
        case "${1}" in
        -y | --yes)
            _FFI_BUILD_FROM_SOURCE_INPUT=1
            shift
            ;;
        -a | --all)
            echo "builder clone and building"
            shift
            if [[ -n "${1}" ]]; then
                if [ "${1}" = "2k" ]; then
                    all 2k
                elif [ "${1}" = "all" ]; then
                    all_full
                elif [ "${1}" = "webapi" ]; then
                    all_webapi
                else
                    Usage
                fi
            else
                all
            fi
            exit 0
            ;;
        -b | --build)
            echo "builder building"
            shift
            if [[ -n "${1}" ]]; then
                if [ "${1}" = "2k" ]; then
                    build 2k
                elif [ "${1}" = "all" ]; then
                    build_full
                elif [ "${1}" = "webapi" ]; then
                    build_webapi
                else
                    Usage
                fi
            else
               build
            fi
            exit 0
            ;;
        -c | --config)
            echo "builder config"
            config
            exit 0
            ;;
        --clone)
            echo "builder clone"
            git_clone
            exit 0
            ;;
        -l | --clear)
            echo "builder clear"
            clear
            exit 0
            ;;
        -t | --test)
            echo "builder test"
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
    echo "Usage:"${cmd}" options { -a,--all(2k,all) | -b,--build(2k,all) | -c,--config | --clone | -l,--clear | -t,--test | -h }"
}

all() {
    git_clone
    config
    build_lotus $1
}

all_full() {
    git_clone
    config
    build_lotus full
}

all_webapi() {
    git_clone
    build_webapi
}

build(){
    build_lotus $1
}

build_full() {
    build_lotus full
    build_webapi
}

build_webapi(){
    cd filecoin-webapi
    env RUSTFLAGS="-lhugetlbfs" cargo build --release
    echo ""
    echo -e "\033[34m $ROOT_PATH/filecoin-webapi/target/release/filecoin-webapi \033[0m"
    echo -e "\033[34m `./target/release/filecoin-webapi -V` \033[0m"
    echo ""
    cd -
}

config() {
    echo ""
    echo -e "\033[34m cp -rf $ROOT_PATH/template/* $ROOT_PATH \033[0m"
    cp -rf $ROOT_PATH/template/* $ROOT_PATH
    echo ""
    set +e
    echo -e "\033[34m source select_target.sh \033[0m"
    source select_target.sh
    set -e
    echo ""
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
    rm -rf specs-actors-v0.9.13
    rm -rf specs-actors-v2.3.4
    rm -rf specs-actors-v3.0.3
    rm -rf bellperson
    rm -rf go-jsonrpc
    rm -rf merkletree

    rm -rf chain-validation
    rm -rf go-fil-markets
    rm -rf go-padreader
    rm -rf specs-storage
    rm -rf statediff
    rm -rf test-vectors
    rm -rf fil-sapling-crypto
    rm -rf chain-validation
    rm -rf neptune
    rm -rf neptune-triton
    rm -rf phase2
    rm -rf serialization-vectors
    rm -rf filecoin-webapi
}

git_clone() {

    # filecash/v1.5.0 98cfa158d9c40eb2519d202ac93971539fa0560a
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/lotus.git" lotus "98cfa158d9c40eb2519d202ac93971539fa0560a"
    # filecash/v1.5.0 1b26a73d93a5cfa7096b02c1bfdbf109e790547e
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-storage.git" specs-storage "1b26a73d93a5cfa7096b02c1bfdbf109e790547e"
    # filecash/v1.5.0 bc9f6b2d3c787d74ee30257aad8429d95daf06b9
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/filecoin-ffi.git" filecoin-ffi "bc9f6b2d3c787d74ee30257aad8429d95daf06b9"
    # filecash 3feeceb0cf6c8e18fe64bc68cf755edcbf99f411
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/filecoin-webapi.git" filecoin-webapi "3feeceb0cf6c8e18fe64bc68cf755edcbf99f411"

    # filecash/v1.2.2 88d3d9ff89e035c0b1c3057ecc3e53a82256d785
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/rust-filecoin-proofs-api.git" rust-filecoin-proofs-api "88d3d9ff89e035c0b1c3057ecc3e53a82256d785"
    # filecash/v1.2.2 4411241ffa8d2aabf75affd0f5ec663996bf1674
    # filecash/v1.2.2-sha512-avx 0eaca46a636700bc03f7d4393ff819d6957fe68b
    # filecash/v1.5.0 71a32a4dcd1c18075772307ce041c5295ae845fb
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/rust-fil-proofs.git" rust-fil-proofs "71a32a4dcd1c18075772307ce041c5295ae845fb"
    # filecash/0.21.0 17b0ac21d13e85f76e474e45db24d95181265781
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/merkletree.git" merkletree "filecash/0.21.0"

    # filecash/v1.2.2 26b53042c1689d4c0ccb163a44ab0ac60a192ef4
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/bellman.git" bellperson "26b53042c1689d4c0ccb163a44ab0ac60a192ef4"
    # filecash/v1.2.2 37caaecccf5ab6cb6bd595f97b96ad12fae4db3b
    # filecash/v1.5.0 5d55341d9ad26c3cd8e8887d6d066c26365216e8
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/neptune.git" neptune "5d55341d9ad26c3cd8e8887d6d066c26365216e8"
    # filecash/v1.2.2 753c436bcd446cee8a1672cd8603924cbfa5f3ea
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/neptune-triton.git" neptune-triton "753c436bcd446cee8a1672cd8603924cbfa5f3ea"

    # filecash/v1.5.0-0.9.13 001beb2f7622ca1e02c011b21fd91491c27807e2
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-actors.git" specs-actors-v0.9.13 "001beb2f7622ca1e02c011b21fd91491c27807e2"
    # filecash/v1.5.0-2.3.4 855a1a21c8bb296340c761c637e05ea20c94e523
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-actors.git" specs-actors-v2.3.4 "855a1a21c8bb296340c761c637e05ea20c94e523"
    # filecash/v1.5.0-3.0.3 e4be2dd0d8b966298bd62493b51d4a54d2fd6e44
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-actors.git" specs-actors-v3.0.3 "e4be2dd0d8b966298bd62493b51d4a54d2fd6e44"
    # filecash/v1.2.2 978a8faec08408e83e5a5c0350e39566ac0a9bce
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/go-paramfetch.git" go-paramfetch "978a8faec08408e83e5a5c0350e39566ac0a9bce"
    # filecash/v1.5.0 83265abb312f9d509da4a391b617e00d51fa4c41
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/go-state-types.git" go-state-types "83265abb312f9d509da4a391b617e00d51fa4c41"
    # filecash/v1.2.2 7fb89143805afcf53e1ff14b94615eedfa839e68
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/test-vectors.git" test-vectors "7fb89143805afcf53e1ff14b94615eedfa839e68"

    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/serialization-vectors.git" serialization-vectors "5bfb928910b0"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/go-fil-markets.git" go-fil-markets "v1.1.9"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/go-padreader.git" go-padreader "ed5fae088b20"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/phase2.git" phase2 "v0.11.0"

}

check_yesorno() {
  unset yesorno
  while [ -z $yesorno ]
  do
    echo " "
    read -e -r -p "Are you sure set FFI_BUILD_FROM_SOURCE? [[Y]es/[N]o] " input
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
    echo ""
    echo -e "\033[34m make $1 \033[0m"
    echo ""
    
    cd filecoin-ffi
    make clean
    cd -
    echo "SOURCE_INPUT:$_FFI_BUILD_FROM_SOURCE_INPUT"
    if [ -n "$_FFI_BUILD_FROM_SOURCE_INPUT" ]; then   
        _FFI_BUILD_FROM_SOURCE=1
    else
        check_yesorno
        if [ $yesorno -eq 1 ]; then
            _FFI_BUILD_FROM_SOURCE=1
        else
            _FFI_BUILD_FROM_SOURCE=0
        fi
    fi
    
    set +e
    result=$(grep -m 1 'vendor_id' /proc/cpuinfo | grep "Intel")
    if [[ "$result" != "" ]] ; then
        arch=intel
        export CGO_CFLAGS="-O -D__BLST_PORTABLE__" 
        export CGO_CFLAGS_ALLOW="-O -D__BLST_PORTABLE__"
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
    echo ""
    echo -e "\033[34m $ROOT_PATH/lotus/lotus \033[0m"
    echo -e "\033[34m `./lotus -v` \033[0m"
    echo ""
    cd -
}

main   "$@"
