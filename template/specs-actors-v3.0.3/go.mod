module github.com/filecoin-project/specs-actors/v3

go 1.13

require (
	github.com/filecoin-project/go-address v0.0.5
	github.com/filecoin-project/go-amt-ipld/v2 v2.1.0
	github.com/filecoin-project/go-amt-ipld/v3 v3.0.0
	github.com/filecoin-project/go-bitfield v0.2.3
	github.com/filecoin-project/go-hamt-ipld/v2 v2.0.0
	github.com/filecoin-project/go-hamt-ipld/v3 v3.0.1
	github.com/filecoin-project/go-state-types v0.1.0
	github.com/filecoin-project/specs-actors v0.9.13
	github.com/filecoin-project/specs-actors/v2 v2.3.4
	github.com/ipfs/go-block-format v0.0.3
	github.com/ipfs/go-cid v0.0.7
	github.com/ipfs/go-ipld-cbor v0.0.5
	github.com/ipfs/go-log/v2 v2.1.2-0.20200626104915-0016c0b4b3e4
	github.com/kr/pretty v0.2.1 // indirect
	github.com/minio/blake2b-simd v0.0.0-20160723061019-3f5f724cb5b1
	github.com/minio/sha256-simd v0.1.1
	github.com/multiformats/go-multihash v0.0.14
	github.com/pkg/errors v0.9.1
	github.com/stretchr/testify v1.7.0
	github.com/whyrusleeping/cbor-gen v0.0.0-20210118024343-169e9d70c0c2
	github.com/xorcare/golden v0.6.0
	golang.org/x/sync v0.0.0-20201207232520-09787c993a3a
	golang.org/x/xerrors v0.0.0-20200804184101-5ec99f83aff1
)

replace github.com/filecoin-project/go-state-types => ../go-state-types

replace github.com/filecoin-project/specs-actors => ../specs-actors-v0.9.13

replace github.com/filecoin-project/specs-actors/v2 => ../specs-actors-v2.3.4