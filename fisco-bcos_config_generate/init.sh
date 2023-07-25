node_num=64
rm -rf fisco-bcos_${node_num}peer_network
mkdir fisco-bcos_${node_num}peer_network
cp build_chain.sh fisco-bcos_${node_num}peer_network/bulid_chain.sh
cp  benchmark/* fisco-bcos_${node_num}peer_network
cp -r src fisco-bcos_${node_num}peer_network/src
cd fisco-bcos_${node_num}peer_network

bash bulid_chain.sh -d -l 127.0.0.1:${node_num} -p 30300,20200,8545
config='{
    "caliper": {
        "blockchain": "fisco-bcos",
        "command": {
            "start": "sleep 3s",
            "end": "sleep 3s"
        }
    },
    "fisco-bcos": {
        "config": {
            "privateKey": "bcec428d5205abe0f0cc8a734083908d9eb8563e31f943d760786edf42ad67dd",
            "account": "0x64fa644d2a694681bd6addd6c5e36cccd8dcdde3"
        },
        "network": {
            "nodes": ['
echo  "$config" > networkconfig.json

for ((i=0; i<$node_num; i++))
do
    echo "                {" >> networkconfig.json
    echo "                    \"ip\": \"127.0.0.1\"," >> networkconfig.json
    echo "                    \"rpcPort\": \"$((i + 8545))\"," >> networkconfig.json
    echo "                    \"channelPort\": \"$((i + 20200))\"" >> networkconfig.json
    echo -n "                }" >> networkconfig.json
    if  (( i == node_num - 1 )); then
        echo "" >> networkconfig.json
    else
        echo "," >> networkconfig.json
    fi
done
config='            ],
            "authentication": {
                "key": "nodes/127.0.0.1/sdk/sdk.key",
                "cert": "nodes/127.0.0.1/sdk/sdk.crt",
                "ca": "nodes/127.0.0.1/sdk/ca.crt"
            },
            "groupID": 1,
            "timeout": 100000
        },
        "smartContracts": [
            {
                "id": "helloworld",
                "path": "src/helloworld/HelloWorld.sol",
                "language": "solidity",
                "version": "v0"
            },
            {
                "id": "parallelok",
                "path": "src/transfer/ParallelOk.sol",
                "language": "solidity",
                "version": "v0"
            },
            {
                "id": "dagtransfer",
                "address": "0x0000000000000000000000000000000000005002",
                "language": "precompiled",
                "version": "v0"
            }
        ]
    },
    "info": {
        "Version": "2.0.0",
        "Size": "4 Nodes",
        "Distribution": "Single Host"
    }
}'
echo  "$config" >> networkconfig.json