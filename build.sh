#!/bin/bash
set -e
set -o pipefail

cmd=$(basename $0)

ARGS=$(getopt -o a::cblhty -l all::,clone,config,build,clear,help,test,yes -n "${cmd}" -- "$@")
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
echo -e "\033[34m http_proxy=$http_proxy \033[0m"
echo -e "\033[34m https_proxy=$https_proxy \033[0m"

setArg() {
   set +e
   unset _FFI_BUILD_FROM_SOURCE_INPUT
   while true; do
       case "${1}" in
	    '' )
		 break
		 ;;
            -h | --help)
                 Usage
                 exit 0
                 ;;
            -y | --yes)
                 _FFI_BUILD_FROM_SOURCE_INPUT=1
                 break;
                 ;;
	    -a | --all | --clone | -b | -c | --config | -l | --clear | -t | --test   )
                 shift 2                 
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
}

main() {
    while true; do
        case "${1}" in
	-y | --yes)
            _FFI_BUILD_FROM_SOURCE_INPUT=1
            shift
	    ;;
        -a | --all)
            echo "builder building..."
            shift
            if [[ -n "${1}" ]]; then
                if [ "${1}" = "2k" ]; then
                    all_2k
                elif [ "${1}" = "all" ]; then
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
	-b | --build)
	    echo "builder building"
	    shift
            if [[ -n "${1}" ]]; then
                if [ "${1}" = "2k" ]; then
                    build_2k
                elif [ "${1}" = "all" ]; then
                    build_full
	        elif [ "${1}" = "--" ]; then
		    build
                fi
                shift
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

build(){
    build_lotus
}

build_2k() {
    build_lotus 2k
}

build_full() {
    build_lotus full
}

config() {
    echo ""
    echo -e "\033[34m cp -rf $ROOT_PATH/template/* $ROOT_PATH \033[0m"
    cp -rf $ROOT_PATH/template/* $ROOT_PATH
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
    rm -rf specs-actors-v2.3.2
    rm -rf bellperson
    rm -rf go-jsonrpc

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
}

git_clone() {

    # filecash/v1.2.2 auto
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/lotus.git" lotus "9b7f885d4ce9ff4d6403207d9cba09ac864372e9"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/filecoin-ffi.git" filecoin-ffi "20771c8dec42211bb7cd618ce474bd6aea81e36c"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/rust-filecoin-proofs-api.git" rust-filecoin-proofs-api "5e8c7b2143656405e7d56f585233493de9342544"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/rust-fil-proofs.git" rust-fil-proofs "59de386b84a89943082f4a0b697b888b4a859502"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-actors.git" specs-actors-v0.9.13 "001beb2f7622ca1e02c011b21fd91491c27807e2"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-actors.git" specs-actors-v2.3.2 "aec247d3c09799ac2ceffeefc137ff5cb589e817"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/go-paramfetch.git" go-paramfetch "978a8faec08408e83e5a5c0350e39566ac0a9bce"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/go-state-types.git" go-state-types "c2675f0918ddf6d571721296dc5e2242115d26da"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/bellman.git" bellperson "26b53042c1689d4c0ccb163a44ab0ac60a192ef4"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/neptune.git" neptune "37caaecccf5ab6cb6bd595f97b96ad12fae4db3b"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/neptune-triton.git" neptune-triton "753c436bcd446cee8a1672cd8603924cbfa5f3ea"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/test-vectors.git" test-vectors "7fb89143805afcf53e1ff14b94615eedfa839e68"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-storage.git" specs-storage "bd65c906c81592ce629c923fa81013125745f864"

    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/go-fil-markets.git" go-fil-markets "v1.0.9"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/go-padreader.git" go-padreader "ed5fae088b20"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/phase2.git" phase2 "v0.11.0"
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
    cd -
}

setArg "$@"
main   "$@"
