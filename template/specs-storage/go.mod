module github.com/filecoin-project/specs-storage

go 1.13

require (
	github.com/filecoin-project/go-state-types v0.0.0-20200904021452-1883f36ca2f4
	github.com/filecoin-project/specs-actors v0.9.4
	github.com/ipfs/go-cid v0.0.7
	golang.org/x/crypto v0.0.0-20191011191535-87dc89f01550 // indirect
	golang.org/x/sys v0.0.0-20190826190057-c7b8b68b1456 // indirect
)

replace github.com/filecoin-project/specs-actors => ../specs-actors-v0.9.13

replace github.com/filecoin-project/go-state-types => ../go-state-types

