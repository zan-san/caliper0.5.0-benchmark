# fabric-4peer-1order deploy package

## 1 config 
workdir 
```
 ~/caliper0.5.0-benchmark/fabric_4peer_network 
```
execute command
```
./init.sh
```
result like 
```
a@a-VirtualBox:~/caliper0.4.2-benchmark/fabric_4peer_network$ ./init.sh 
org1.aaa.com
org2.aaa.com
org3.aaa.com
org4.aaa.com
2023-06-12 09:48:11.482 CST [common.tools.configtxgen] main -> INFO 001 Loading configuration
2023-06-12 09:48:11.521 CST [common.tools.configtxgen.localconfig] completeInitialization -> INFO 002 orderer type: etcdraft
........
........
2023-06-12 09:48:11.829 CST [common.tools.configtxgen] doOutputAnchorPeersUpdate -> INFO 004 Writing anchor peer update

```
## 2 deploy 
execute command
```
docker-compose up
```
## 3 add order and peer join  channel and deploy chaincode

open a new command line.  
execute command
```
docker exec -it cli bash
```
it`s open the docker fabric-cli bash

excute command
```
./use_by_cli.sh
```
## 4 test by caliper0.5.0
workdir 
```
 ~/caliper0.5.0-benchmark
```
command
binding fabric STU
```
npx caliper bind --caliper-bind-sut fabric --caliper-bind-sdk 2.2.0

```
run caliper benchmark
```
npx caliper launch manager \
--caliper-workspace fabric_4peer_network \
--caliper-benchconfig caliper_config/config.yaml \
--caliper-networkconfig caliper_config/network.yaml \
--caliper-fabric-gateway-enabled \
--caliper-fabric-gateway-discovery \
--caliper-flow-only-test 
```
## 5 down 
open report.html to check result
