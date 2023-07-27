# fabric network generate package
follow this to generate a fabric test network
## 1. write the network node number in `init.sh`

init.sh look like this
```
node_num=64
rm -rf fabric_${node_num}peer_network
mkdir fabric_${node_num}peer_network
cp -r bin fabric_${node_num}peer_network/bin
cp -r caliper_config fabric_${node_num}peer_network/caliper_config
.......
.......
```
change the `node_num` to the network node number.  
now it is 64,mean this network has 64 fabric nodes.

## 2. run `init.sh` to generate network config file
```
cd ~/caliper0.5.0-benchmark/fabric_config_generate
./init.sh
```
## 3.open the config dir and start network
for example,now node number equal 64. `init.sh` will generate dir `fabric_64peer_network`.
```
cd fabric_64peer_network
docker-compose up
```
run uper command to start network

## 4.add order and peer join  channel and deploy chaincode

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
## 5.use caliper to test network
change the node number **64** to your network node number !!
```
cd ~/caliper0.5.0-benchmark
npx caliper bind --caliper-bind-sut fabric:2.2

npx caliper launch manager \
--caliper-workspace fabric_config_generate/fabric_64peer_network \
--caliper-benchconfig caliper_config/config.yaml \
--caliper-networkconfig caliper_config/network.yaml \
--caliper-fabric-gateway-enabled \
--caliper-fabric-gateway-discovery \
--caliper-flow-only-test 
```
## 6. see result


