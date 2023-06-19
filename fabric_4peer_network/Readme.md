# fabric-4peer-1order deploy package

## 1 deploy 
workdir -> this package 

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
it`s create fabric network config file and start docker-compose

## 2 add order and peer join  channel

open a new command line.  
execute command
```
docker exec -it cli bash
```
