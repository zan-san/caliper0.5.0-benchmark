# delete docker container
docker rm $(docker ps -qa --filter ancestor=hyperledger/fabric-tools:2.2)
docker rm $(docker ps -qa --filter ancestor=hyperledger/fabric-peer:2.2)
docker rm $(docker ps -qa --filter ancestor=hyperledger/fabric-orderer:2.2)
# 创建加密材料
rm -rf crypto-config
bin/cryptogen generate --config=./cryptogen-config.yaml


# 创建创世区块和通道
DIRECTORY="./system-genesis-block"
rm -rf $DIRECTORY
mkdir $DIRECTORY
bin/configtxgen -profile OrgsOrdererGenesis -outputBlock $DIRECTORY/genesis.block -channelID orderer-system-channel 

DIRECTORY="./channel-artifacts"
rm -rf $DIRECTORY
mkdir -p $DIRECTORY
bin/configtxgen -profile OrgsChannel -outputCreateChannelTx $DIRECTORY/channel.tx -channelID app-channel

generate_anchor_peer_update() {
  local org_id="$1"
  local directory="$2"
  
  bin/configtxgen -outputAnchorPeersUpdate "${directory}/Org${org_id}MSPanchors.tx" -channelID app-channel -profile OrgsChannel -asOrg "Org${org_id}MSP"
}

for ((org_id=1; org_id<=16; org_id++))
do
  generate_anchor_peer_update "${org_id}" "${DIRECTORY}"
done

./ccp-generate.sh