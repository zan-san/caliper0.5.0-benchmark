node_num=64
rm -rf ethereum_${node_num}peer_network
mkdir ethereum_${node_num}peer_network
cd ethereum_${node_num}peer_network
for i in `seq 1 $node_num`
do
    
    mkdir -p node$i/keystore
    echo password > node$i/keystore/password
    geth --datadir node$i account new --password node$i/keystore/password
done 
address=()
for ((i=0; i<$node_num; i++))
do
    filename="node$((i + 1))/keystore/UTC*"
    json=$(cat $filename)
    address[$i]=$(echo "$json" | grep -o '"address":"[^"]*' | sed 's/"address":"//')
done 
config='{
    "config": {
      "chainId": 12345,
      "homesteadBlock": 0,
      "eip150Block": 0,
      "eip155Block": 0,
      "eip158Block": 0,
      "byzantiumBlock": 0,
      "constantinopleBlock": 0,
      "petersburgBlock": 0,
      "istanbulBlock": 0,
      "muirGlacierBlock": 0,
      "berlinBlock": 0,
      "londonBlock": 0,
      "arrowGlacierBlock": 0,
      "grayGlacierBlock": 0,
      "clique": {
        "period": 5,
        "epoch": 30000
      }
    },
    "difficulty": "1",
    "gasLimit": "0xfffffffffffffff",
    "extradata": "'

echo -n "$config" > genesis.json
echo -n 0x0000000000000000000000000000000000000000000000000000000000000000${address[0]}0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 >> genesis.json
echo '",' >> genesis.json
echo '    "alloc": {' >> genesis.json
for ((i=0; i<$node_num; i++))
do
    echo  -n '      "'${address[i]}'": { "balance": "500000000000000000000000000000000000000000000" }'>> genesis.json
    if [ $i != $((node_num - 1)) ]; then
        echo  "," >> genesis.json
    else
        echo >> genesis.json
    fi
done 
echo '    }
  }'>>genesis.json



for ((i=1; i<=$node_num; i++))
do
geth init --datadir node$i genesis.json
done 

bootnode -genkey boot.key
boot_addr=`bootnode -nodekey boot.key -addr :30305 -writeaddress`
boot_addr="enode://$boot_addr@127.0.0.1:0?discport=30305"

config='
version: "3"

services:
  bootnode:
    image: ethereum/client-go:alltools-v1.11.6
    container_name: bootnode
    volumes:
      - ./boot.key:/root/boot.key
    network_mode: host
    command: 
      - bootnode
      - --nodekey=root/boot.key 
      - --addr=:30305
'
echo  "$config" > docker-compose.yaml

for ((i=1; i<=$node_num; i++))
do
    if [ $i == 1 ]; then
    config_node="
  node$i:
    image: ethereum/client-go:alltools-v1.11.6
    container_name: node$i
    volumes:
      - ./node$i:/root/node$i
    network_mode: host
    command:
      - geth
      - --datadir=/root/node$i
      - --port=$((i + 8100))
      - --bootnodes=$boot_addr
      - --networkid=123123
      - --unlock=0x${address[i-1]}
      - --authrpc.port=$((i + 11110))
      - --password=/root/node$i/keystore/password

      - --ws
      - --ws.port=$((i + 3333))
      - --ws.api=admin,eth,miner,personal,web3 

      - --mine 
      - --miner.threads=2 
      - --miner.etherbase=0x${address[i-1]}
      - --miner.gasprice=1 

      - --allow-insecure-unlock 
    depends_on:
      - bootnode
"
    else
        config_node="
  node$i:
    image: ethereum/client-go:alltools-v1.11.6
    container_name: node$i
    volumes:
      - ./node$i:/root/node$i
    network_mode: host
    command:
      - geth
      - --datadir=/root/node$i
      - --port=$((i + 8100))
      - --bootnodes=$boot_addr
      - --networkid=123123
      - --unlock=0x${address[i-1]}
      - --authrpc.port=$((i + 11110))
      - --password=/root/node$i/keystore/password

      - --ws
      - --ws.port=$((i + 3333))
      - --ws.api=admin,eth,miner,personal,web3 

      - --allow-insecure-unlock 
    depends_on:
      - bootnode
      - node$((i - 1))
"
    fi
    echo  "$config_node" >> docker-compose.yaml
done 


config='{
    "caliper": {
        "blockchain": "ethereum",
        "command" : {
            "start": "",
            "end" : ""
          }
    },
    "ethereum": {
        "url": "ws://localhost:3334",'
echo  "$config" > networkconfig.json

echo  "        \"contractDeployerAddress\": \"0x${address[0]}\"," >> networkconfig.json
echo '        "contractDeployerAddressPassword": "password",' >> networkconfig.json
echo "        \"fromAddress\": \"0x${address[0]}\"," >> networkconfig.json
config='        "fromAddressPassword": "password",
        "transactionConfirmationBlocks": 2,
        "contracts": {
            "test": {
                "path": "contracts/test.json",

                "gas": {
                    "add": 70000,
                    "mul": 70000,
                    "div": 70000,
                    "get": 70000,
                    "set": 70000,
                    "transferAsset":70000
                },
                "abi": [        
                        {
                        "inputs": [
                            {
                                "internalType": "uint256",
                                "name": "n",
                                "type": "uint256"
                            }
                        ],
                        "name": "add",
                        "outputs": [
                            {
                                "internalType": "uint256",
                                "name": "",
                                "type": "uint256"
                            }
                        ],
                        "stateMutability": "pure",
                        "type": "function"
                        },
                        {
                            "inputs": [
                                {
                                    "internalType": "uint256",
                                    "name": "n",
                                    "type": "uint256"
                                }
                            ],
                            "name": "get",
                            "outputs": [
                                {
                                    "internalType": "string",
                                    "name": "",
                                    "type": "string"
                                }
                            ],
                            "stateMutability": "view",
                            "type": "function"
                        },
                        {
                            "inputs": [
                                {
                                    "internalType": "string",
                                    "name": "str",
                                    "type": "string"
                                }
                            ],
                            "name": "set",
                            "outputs": [],
                            "stateMutability": "nonpayable",
                            "type": "function"
                        },
                        {
                            "inputs":
                            [
                              {
                                "internalType": "string",
                                "name": "sender",
                                "type": "string"
                              },
                              {
                                "internalType": "string",
                                "name": "receiver",
                                "type": "string"
                              }
                            ],
                            "name": "transferAsset",
                            "outputs": [],
                            "stateMutability": "nonpayable",
                            "type": "function"
                          }
                ],'
echo  "$config" >> networkconfig.json
echo "                \"address\": \"0x${address[0]}\"" >> networkconfig.json
echo '            }
        }
    }
}' >> networkconfig.json

cd ..
cp -r contracts ethereum_${node_num}peer_network/contracts
cp -r benchmarks ethereum_${node_num}peer_network/benchmarks