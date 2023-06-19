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

bin/configtxgen -outputAnchorPeersUpdate $DIRECTORY/Org1MSPanchors.tx -channelID app-channel -profile OrgsChannel -asOrg Org1MSP

bin/configtxgen -outputAnchorPeersUpdate $DIRECTORY/Org2MSPanchors.tx -channelID app-channel -profile OrgsChannel -asOrg Org2MSP

bin/configtxgen -outputAnchorPeersUpdate $DIRECTORY/Org3MSPanchors.tx -channelID app-channel -profile OrgsChannel -asOrg Org3MSP

bin/configtxgen -outputAnchorPeersUpdate $DIRECTORY/Org4MSPanchors.tx -channelID app-channel -profile OrgsChannel -asOrg Org4MSP

./ccp-generate.sh