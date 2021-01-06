# lotus_builder

## Installation Compilation Environment
bash env.sh


## Compile lotus/lotus-miner/lotus-worker
bash build.sh -a

## Compile lotus-shed/lotus-bench
bash build.sh -a 
cd lotus && make lotus-shed lotus-bench
