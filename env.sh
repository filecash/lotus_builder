#!/bin/bash

check_env() {
  # env
  sudo apt install mesa-opencl-icd ocl-icd-opencl-dev hwloc libhwloc-dev -y
  sudo add-apt-repository ppa:longsleep/golang-backports -y
  sudo apt update
  sudo apt install gcc git bzr jq pkg-config mesa-opencl-icd ocl-icd-opencl-dev gdisk zhcon g++ llvm clang -y
  
  if [ -z $GOPROXY ]; then
    sudo echo "#GOPROXY
    export GO111MODULE=on
    export GOPROXY=https://goproxy.cn
    export GOPATH=$HOME/gopath
    " >> /etc/profile
  fi
  
  if [ -z $RUSTUP_DIST_SERVER ]; then
    sudo echo "# RUST
    export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
    export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup
    " >> /etc/profile
  fi
  
  source /etc/profile
}

check_go() {
  RESULT=$(go version)
  RESULT=${RESULT:13:7}
  #echo $RESULT
  RESULT=${RESULT%.*}
  echo $RESULT
  if [ -z $RESULT ] || [ `expr $RESULT \> 1.13` -eq 0 ]; then
    echo "go version must > 1.13 . "
    # go install
    sudo add-apt-repository ppa:longsleep/golang-backports -y
    sudo apt-get update
    sudo apt install golang-go -y
    
    # check
    go version && go env
  fi
  echo " "
  return 1
}

check_rustup() {
  RESULT=$(rustup --version)
  RESULT=${RESULT:7:7}
  #echo $RESULT
  RESULT=${RESULT%.*}
  echo $RESULT
  if [ -z $RESULT ] || [ `expr $RESULT \> 1.20` -eq 0 ]; then
    echo "rustup version must > 1.20 . "
    # rustup env config
    if [ ! -s "$HOME/.rustup/config" ]; then
      echo '
      [source.crates-io]
      registry = "https://github.com/rust-lang/crates.io-index"
      replace-with = 'tuna'
      [source.tuna]
      registry = "https://mirrors.tuna.tsinghua.edu.cn/git/crates.io-index.git"
      ' > $HOME/.rustup/config
    fi
    # rustup install
    apt install libcurl4 curl -y
    curl https://sh.rustup.rs -sSf | sh -s -- -y && source $HOME/.cargo/env
    
    # check
    rustup --version
  fi
  echo " "
  return 1
}

check_env
check_go
check_rustup
