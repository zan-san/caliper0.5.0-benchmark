# fisco-bcos network generate package
follow this to generate a fisco-bcos test network
## 1. write the network node number in `init.sh`

init.sh look like this
```
node_num=64
rm -rf fisco-bcos_${node_num}peer_network
mkdir fisco-bcos_${node_num}peer_network
cp build_chain.sh fisco-bcos_${node_num}peer_network/bulid_chain.sh
.......
.......
```
change the `node_num` to the network node number.  
now it is 64,mean this network has 64 fisco-bcos nodes.

## 2. run `init.sh` to generate network config file
```
cd ~/caliper0.5.0-benchmark/fisco-bcos_config_generate
./init.sh
```
## 3.open the config dir and start network
for example,now node number equal 64. `init.sh` will generate dir `fisco-bcos_64peer_network`.
```
cd fisco-bcos_64peer_network
bash nodes/127.0.0.1/start_all.sh
```
run uper command to start network

## 4.use caliper to test network
change the node number **64** to your network node number !!
```
cd ~/caliper0.5.0-benchmark
npx caliper bind --caliper-bind-sut fisco-bcos --caliper-bind-sdk 2.9.1

npx caliper launch manager \
--caliper-workspace fisco-bcos_config_generate/fisco-bcos_64peer_network \
--caliper-benchconfig benchconfig.yaml \
--caliper-networkconfig networkconfig.json \
--caliper-fabric-gateway-enabled \
--caliper-fabric-gateway-discovery 
```
## 5. see result

