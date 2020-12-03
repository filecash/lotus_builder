SHELL=/usr/bin/env bash

all: build
.PHONY: all

# git submodules that need to be loaded
SUBMODULES:=

# things to clean up, e.g. libfilecoin.a
CLEAN:=

FFI_PATH:=../filecoin-ffi/
FFI_DEPS:=libfilecoin.a filecoin.pc filecoin.h
FFI_DEPS:=$(addprefix $(FFI_PATH),$(FFI_DEPS))

DEPS_OPT:
	cp -rf ../filecoin-ffi/filcrypto.pc ./extern/filecoin-ffi
	cp -rf ../filecoin-ffi/filcrypto.h ./extern/filecoin-ffi
	cp -rf ../filecoin-ffi/libfilcrypto.a ./extern/filecoin-ffi

deps: $(BUILD_DEPS)

.PHONY: deps

$(FFI_DEPS): build/.filecoin-ffi-install ;

# dummy file that marks the last time the filecoin-ffi project was built
build/.filecoin-ffi-install: $(FFI_PATH)
	$(MAKE) -C $(FFI_PATH) $(FFI_DEPS:$(FFI_PATH)%=%)
	@touch $@

SUBMODULES+=$(FFI_PATH)
BUILD_DEPS+=build/.filecoin-ffi-install
CLEAN+=build/.filecoin-ffi-install

$(SUBMODULES): build/.update-submodules ;

# dummy file that marks the last time submodules were updated
build/.update-submodules:
	git submodule update --init --recursive
	touch $@

CLEAN+=build/.update-submodules

# build and install any upstream dependencies, e.g. filecoin-ffi
deps: $(BUILD_DEPS) DEPS_OPT
.PHONY: deps

test: $(BUILD_DEPS) DEPS_OPT
	RUST_LOG=info go test -v -timeout 120m ./...
.PHONY: test

lint: $(BUILD_DEPS) DEPS_OPT
	golangci-lint run -v --concurrency 2 --new-from-rev origin/master
.PHONY: lint

build: $(BUILD_DEPS) DEPS_OPT
	go build -v $(GOFLAGS) ./...
.PHONY: build

clean:
	rm -rf $(CLEAN)
	-$(MAKE) -C $(FFI_PATH) clean
.PHONY: clean
