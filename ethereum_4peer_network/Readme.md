npx caliper bind --caliper-bind-sut ethereum 


npx caliper launch manager \
--caliper-workspace ethereum_4peer_network \
--caliper-benchconfig benchmarks/config.yaml \
--caliper-networkconfig networkconfig.json \
--caliper-flow-only-test 

warning: node_modules/number-to-bn/dist/number-to-bn.js  