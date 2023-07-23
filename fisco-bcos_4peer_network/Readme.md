##  test by caliper0.5.0
workdir 
```
 ~/caliper0.5.0-benchmark
```
command
binding fisco-bcos STU
```
npx caliper bind --caliper-bind-sut fisco-bcos --caliper-bind-sdk 2.9.1
```
run caliper benchmark

```
npx caliper launch manager \
--caliper-workspace fisco-bcos_4peer_network \
--caliper-benchconfig benchconfig.yaml \
--caliper-networkconfig networkconfig.json \
--caliper-fabric-gateway-enabled \
--caliper-fabric-gateway-discovery 
```
## 5 down 
open report.html to check result


bash build_chain.sh -d -l 127.0.0.1:4 -p 30300,20200,8545
bash nodes/127.0.0.1/start_all.sh