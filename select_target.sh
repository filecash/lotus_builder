#!/bin/bash
is_amd=`lscpu | grep AMD`
is_intel=`lscpu | grep Intel`
have_avx=`lscpu | grep avx`
have_avx2=`lscpu | grep avx2`
if [ "$is_amd" != "" ]; then
    echo "AMD"
    if [ "$have_avx2" != "" ]; then
        echo "use avx2"
        cp template/sha2raw/Cargo_avx2.toml rust-fil-proofs/sha2raw/Cargo.toml
    else
        echo "use asm"
        cp template/sha2raw/Cargo_asm.toml rust-fil-proofs/sha2raw/Cargo.toml
    fi
elif [ "$is_intel" != "" ]; then
    echo "INTEL"
    if [ "$have_avx2" != "" ]; then
        echo "use avx2"
        cp template/sha2raw/Cargo_avx2.toml rust-fil-proofs/sha2raw/Cargo.toml
    elif [ "$have_avx" != "" ]; then
        echo "use avx"
        cp template/sha2raw/Cargo_avx.toml rust-fil-proofs/sha2raw/Cargo.toml
    else
        echo "use asm"
        cp template/sha2raw/Cargo_asm.toml rust-fil-proofs/sha2raw/Cargo.toml
    fi
else
    echo "UNKNOW"
fi
