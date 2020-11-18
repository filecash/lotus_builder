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
    echo "Usage:"${cmd}" options {-a,--all(2k) | --clone | -c,--config | -l,--clear | -t,--test | -h}"
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

config() {
    # git_clone
    go_mod
    m_makefile
    rust_mod
    sha512_rust_dep
}

clear() {
    rm -rf lotus
    rm -rf rust-filecoin-proofs-api
    rm -rf rust-fil-proofs
    rm -rf specs-actors
    rm -rf filecoin-ffi
    rm -rf go-state-types
    rm -rf bellman
    rm -rf go-paramfetch

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
    export http_proxy=
    export https_proxy=

    # filecash/v0.7.0
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/lotus.git" lotus "240564ac10514923908eb540e6786a1069b1412a"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/rust-filecoin-proofs-api.git" rust-filecoin-proofs-api "ba88f0ca4db5f38c96edcaaeadb7fefca16157fd"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/rust-fil-proofs.git" rust-fil-proofs "cbf5f8b229847596a9223c79d5aac2d1b0e3ac2b"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/specs-actors.git" specs-actors "c02a06a184850c098cc3ef8d0ca8ccb9d8383aac"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/filecoin-ffi.git" filecoin-ffi "803326afeaf27d6b827668447c270fce6ad4898d"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/go-state-types.git" go-state-types "6bb49fe7c7924256914b431125259a919fa8c880"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/bellman.git" bellman "bf127c5c9bf7791235ce3ed72e5596fa897e5721"
    source $CLONE_AND_CHECKOUT "https://github.com/filecash/go-paramfetch.git" go-paramfetch "829f513be2b5dacc424ef6be1762c39c7d81b420"

    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/chain-validation.git" chain-validation "40c22fe26eefba10b7bbb24bf8e742b2a0e2478c"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/go-fil-markets.git" go-fil-markets "v0.6.0"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/go-padreader.git" go-padreader "ed5fae088b20"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/specs-storage.git" specs-storage "ed2e5cd13796"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/statediff.git" statediff "v0.0.1"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/test-vectors" test-vectors "7d3becbeb5b932baed419c43390595b5e5cece12"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/sapling-crypto.git" fil-sapling-crypto "v0.6.3"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/neptune.git" neptune "v1.2.0"
    source $CLONE_AND_CHECKOUT "https://github.com/filecoin-project/phase2.git" phase2 "v0.8.0"
}

go_mod() {
    source $LOTUS_GO_MOD "add" lotus "replace github.com/filecoin-project/chain-validation => ../chain-validation"
    source $LOTUS_GO_MOD "add" lotus "replace github.com/filecoin-project/go-fil-markets => ../go-fil-markets"
    source $LOTUS_GO_MOD "add" lotus "replace github.com/filecoin-project/go-padreader => ../go-padreader"
    source $LOTUS_GO_MOD "add" lotus "replace github.com/filecoin-project/specs-storage => ../specs-storage"
    source $LOTUS_GO_MOD "add" lotus "replace github.com/filecoin-project/statediff => ../statediff"
    source $LOTUS_GO_MOD "add" lotus "replace  github.com/filecoin-project/go-state-types => ../go-state-types"
    source $LOTUS_GO_MOD "add" lotus "replace github.com/filecoin-project/specs-actors => ../specs-actors"
    source $LOTUS_GO_MOD "add" lotus "replace github.com/filecoin-project/go-paramfetch => ../go-paramfetch"
    source $LOTUS_GO_MOD "replace" lotus "replace\sgithub.com\/filecoin-project\/filecoin-ffi\s=>\s.\/extern\/filecoin-ffi" "replace github.com\/filecoin-project\/filecoin-ffi\ =>\ ..\/filecoin-ffi"
    source $LOTUS_GO_MOD "replace" lotus "replace\sgithub.com\/filecoin-project\/test-vectors\s=>\s.\/extern\/test-vectors" "replace github.com\/filecoin-project\/test-vectors\ =>\ ..\/test-vectors"

    source $LOTUS_GO_MOD "add" chain-validation "replace github.com/filecoin-project/specs-actors => ../specs-actors"

    source $LOTUS_GO_MOD "add" go-fil-markets "replace github.com/filecoin-project/specs-actors => ../specs-actors"

    source $LOTUS_GO_MOD "add" go-fil-markets "replace github.com/filecoin-project/go-state-types => ../go-state-types"

    source $LOTUS_GO_MOD "add" go-padreader "replace github.com/filecoin-project/specs-actors => ../specs-actors"

    source $LOTUS_GO_MOD "add" go-padreader "replace github.com/filecoin-project/go-state-types => ../go-state-types"

    source $LOTUS_GO_MOD "add" specs-storage "replace github.com/filecoin-project/specs-actors => ../specs-actors"

    source $LOTUS_GO_MOD "add" specs-storage "replace github.com/filecoin-project/go-state-types => ../go-state-types"

    source $LOTUS_GO_MOD "add" specs-actors "replace github.com/filecoin-project/go-state-types => ../go-state-types"

    source $LOTUS_GO_MOD "add" filecoin-ffi "replace github.com/filecoin-project/specs-actors => ../specs-actors"

    source $LOTUS_GO_MOD "add" filecoin-ffi "replace github.com/filecoin-project/go-state-types => ../go-state-types"

    source $LOTUS_GO_MOD "add" test-vectors "replace github.com/filecoin-project/specs-actors => ../specs-actors"

    source $LOTUS_GO_MOD "add" test-vectors "replace github.com/filecoin-project/go-state-types => ../go-state-types"

    source $LOTUS_GO_MOD "add" statediff "replace github.com/filecoin-project/specs-actors => ../specs-actors"
    source $LOTUS_GO_MOD "replace" lotus "replace\sgithub.com\/filecoin-project\/filecoin-ffi\s=>\s.\/extern\/filecoin-ffi" "replace github.com\/filecoin-project\/filecoin-ffi\ =>\ ..\/filecoin-ffi"
    source $LOTUS_GO_MOD "replace" statediff "replace\sgithub.com\/filecoin-project\/sector-storage\s=>\s.\/extern\/sector-storage" "replace github.com\/filecoin-project\/filecoin-ffi\ =>\ ..\/lotus\/extern\/sector-storage"

    # modify sector-storage go.mod
    # source $LOTUS_GO_MOD "replace" sector-storage "replace\sgithub.com\/filecoin-project\/filecoin-ffi\s=>\s.\/extern\/filecoin-ffi" "replace github.com\/filecoin-project\/filecoin-ffi\ =>\ ..\/filecoin-ffi"

    # modify storage-fsm go.mod
    # source $LOTUS_GO_MOD "add" storage-fsm "replace github.com/filecoin-project/sector-storage => ../sector-storage"
    # source $LOTUS_GO_MOD "replace" storage-fsm "replace\sgithub.com\/filecoin-project\/filecoin-ffi\s=>\s.\/extern\/filecoin-ffi" "replace github.com\/filecoin-project\/filecoin-ffi\ =>\ ..\/filecoin-ffi"

}

sha512_rust_dep() {

    #rust-fil-proofs
    cp template/sha512_rust/fil-proofs-tooling/Cargo rust-fil-proofs/fil-proofs-tooling/Cargo.toml
    cp template/sha512_rust/filecoin-proofs/Cargo rust-fil-proofs/filecoin-proofs/Cargo.toml
    cp template/sha512_rust/storage-proofs/core/Cargo rust-fil-proofs/storage-proofs/core/Cargo.toml
    cp template/sha512_rust/storage-proofs/porep/Cargo rust-fil-proofs/storage-proofs/porep/Cargo.toml
    cp template/sha512_rust/storage-proofs/post/Cargo rust-fil-proofs/storage-proofs/post/Cargo.toml

    #neptune
    cp template/sha512_rust/neptune/Cargo neptune/Cargo.toml
    #fil-sapling-crypto
    cp template/sha512_rust/fil-sapling-crypto/Cargo fil-sapling-crypto/Cargo.toml
    #phase2
    cp template/sha512_rust/phase2/Cargo phase2/Cargo.toml
}

m_makefile() {
    source $LOTUS_MAKEFILE "template" ${ROOT_PATH}/template/lotus/Makefile.template ${ROOT_PATH}/lotus
    # source $LOTUS_MAKEFILE "replace" lotus "FFI_PATH:=extern\/filecoin-ffi\/" "FFI_PATH:=..\/filecoin-ffi\/"
}

rust_mod() {
    # ffi
    source $FFI_TEMPLATE ${ROOT_PATH}/template/ffi/rust.Cargo.toml.template filecoin-ffi/rust ${ROOT_PATH}"\/rust-filecoin-proofs-api"

    # rust-filecoin-proofs-api
    source $RUST_MOD "replace" rust-filecoin-proofs-api "filecoin-proofs-v1\s=\s{\spackage\s=\s\"filecoin-proofs\",\sversion\s=\s\"5.1.1\"\s}" "filecoin-proofs-v1 = { package = \"filecoin-proofs\", path = \""${ROOT_PATH}"\/rust-fil-proofs\/filecoin-proofs\" }"

}

just_for_test() {
    # source $CLONE_AND_CHECKOUT "https://dev.cqultra.com:8008/gitea/CST/rust-filecoin-proofs-api.git" rust-filecoin-proofs-api "yuncun/v4.0.4"

    # rust_mod

    build_lotus 2k
}

build_lotus() {
    cd filecoin-ffi
    make clean
    cd -

    _FFI_BUILD_FROM_SOURCE=1
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
exit
