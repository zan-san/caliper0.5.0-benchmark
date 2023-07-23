node_num=4
rm -rf fabric_${node_num}peer_network
mkdir fabric_${node_num}peer_network
cp -r bin fabric_${node_num}peer_network/bin
cp -r caliper_config fabric_${node_num}peer_network/caliper_config
cp -r chaincode fabric_${node_num}peer_network/chaincode
cp ccp-template.json fabric_${node_num}peer_network/ccp-template.json
cp ccp-template.yaml fabric_${node_num}peer_network/ccp-template.yaml

cd fabric_${node_num}peer_network

docker rm $(docker ps -qa --filter ancestor=hyperledger/fabric-tools:2.2)
docker rm $(docker ps -qa --filter ancestor=hyperledger/fabric-peer:2.2)
docker rm $(docker ps -qa --filter ancestor=hyperledger/fabric-orderer:2.2)

config='OrdererOrgs:
  - Name: Orderer
    Domain: aaa.com
    EnableNodeOUs: false
    Specs:
      - Hostname: orderer
PeerOrgs:'
echo "$config" > cryptogen-config.yaml
for ((i=1; i<=$node_num; i++))
do
    config="  - Name: Org$i
    Domain: org$i.aaa.com
    EnableNodeOUs: false
    Template:
      Count: 1
    Users:
      Count: 1"
    echo "$config" >> cryptogen-config.yaml
done


config="Organizations:
    - &OrdererOrg
        Name: OrdererOrg
        ID: OrdererMSP
        MSPDir: ./crypto-config/ordererOrganizations/aaa.com/msp
        Policies:
            Readers:
                Type: Signature
                Rule: \"OR('OrdererMSP.member')\"
            Writers:
                Type: Signature
                Rule: \"OR('OrdererMSP.member')\"
            Admins:
                Type: Signature
                Rule: \"OR('OrdererMSP.admin')\"
        OrdererEndpoints: 
            - orderer.aaa.com:7050
       "
echo "$config" > configtx.yaml
for ((i=1; i<=$node_num; i++))
do
    config="    - &Org$i
        Name: Org${i}MSP
        ID: Org${i}MSP
        MSPDir: ./crypto-config/peerOrganizations/org$i.aaa.com/msp
        Policies:
            Readers:
                Type: Signature
                Rule: \"OR('Org${i}MSP.member')\"
            Writers:
                Type: Signature
                Rule: \"OR('Org${i}MSP.member')\"
            Admins:
                Type: Signature
                Rule: \"OR('Org${i}MSP.admin')\"
            Endorsement:
                Type: Signature
                Rule: \"OR('Org${i}MSP.member')\"
        AnchorPeers:
            - Host: peer0.org$i.aaa.com
              Port: $((i * 10 + 7041))"
    echo "$config" >> configtx.yaml
done
config='Capabilities:
    Channel: &ChannelCapabilities
        V2_0: true

    Orderer: &OrdererCapabilities
        V2_0: true

    Application: &ApplicationCapabilities
        V2_0: true

Application: &ApplicationDefaults
    Organizations:
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
        Endorsement:
            Type: ImplicitMeta
            Rule: "MAJORITY Endorsement"
    Capabilities:
        <<: *ApplicationCapabilities

Orderer: &OrdererDefaults
    OrdererType: etcdraft
    EtcdRaft:
        Consenters:
        - Host: orderer.aaa.com
          Port: 7050
          ClientTLSCert: ./crypto-config/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/tls/server.crt
          ServerTLSCert: ./crypto-config/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/tls/server.crt
    Addresses:
        - orderer.aaa.com:7050
    BatchTimeout: 2s
    BatchSize:
        MaxMessageCount: 10
        AbsoluteMaxBytes: 99 MB
        PreferredMaxBytes: 512 KB
    Organizations:
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
        BlockValidation:
            Type: ImplicitMeta
            Rule: "ANY Writers"

Channel: &ChannelDefaults
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
    Capabilities:
        <<: *ChannelCapabilities
Profiles:
    OrgsOrdererGenesis:
        <<: *ChannelDefaults
        Orderer:
            <<: *OrdererDefaults
            Organizations:
                - *OrdererOrg
            Capabilities:
                <<: *OrdererCapabilities
        Consortiums:
            SampleConsortium:
                Organizations:        
'
echo "$config" >> configtx.yaml

for ((i=1; i<=$node_num; i++))
do
    config="                    - *Org$i"
    echo "$config" >> configtx.yaml
done
config='    OrgsChannel:
        Consortium: SampleConsortium
        <<: *ChannelDefaults
        Application:
            <<: *ApplicationDefaults
            Organizations:'
echo "$config" >> configtx.yaml
for ((i=1; i<=$node_num; i++))
do
    config="                - *Org$i"
    echo "$config" >> configtx.yaml
done
config='            Capabilities:
                <<: *ApplicationCapabilities'
echo "$config" >> configtx.yaml
# 创建加密材料
bin/cryptogen generate --config=./cryptogen-config.yaml

# 创建创世区块和通道
DIRECTORY="./system-genesis-block"
mkdir $DIRECTORY
bin/configtxgen -profile OrgsOrdererGenesis -outputBlock $DIRECTORY/genesis.block -channelID orderer-system-channel

DIRECTORY="./channel-artifacts"
mkdir -p $DIRECTORY
bin/configtxgen -profile OrgsChannel -outputCreateChannelTx $DIRECTORY/channel.tx -channelID app-channel
for ((i=1; i<=$node_num; i++))
do
bin/configtxgen -outputAnchorPeersUpdate $DIRECTORY/Org${i}MSPanchors.tx -channelID app-channel -profile OrgsChannel -asOrg Org${i}MSP
done

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}


#create caliper connect file
for ((i=1; i<=$node_num; i++))
do
    ORG=$i
    P0PORT=$((i * 10 + 7041))
    CAPORT=8000
    PEERPEM=crypto-config/peerOrganizations/org$i.aaa.com/tlsca/tlsca.org$i.aaa.com-cert.pem
    CAPEM=crypto-config/peerOrganizations/org$i.aaa.com/ca/ca.org$i.aaa.com-cert.pem

    echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org$i.aaa.com/connection-org$i.json
    echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org$i.aaa.com/connection-org$i.yaml

done

echo "version: '2'" > docker-compose.yaml

config="networks:
    basic:
        name: fabric_${node_num}peer_test
services:
    orderer.aaa.com:
        extends:
            file:   base/dc-base.yaml
            service: orderer.aaa.com
        container_name: orderer.aaa.com
        networks:
            - basic"
echo "$config" >> docker-compose.yaml

for ((i=1; i<=$node_num; i++))
do
    config="    peer0.org$i.aaa.com:
        extends:
            file:  base/dc-base.yaml
            service: peer0.org$i.aaa.com
        container_name: peer0.org$i.aaa.com
        networks:
            - basic"
    echo "$config" >> docker-compose.yaml
done
config="    cli:
        container_name: cli
        image: hyperledger/fabric-tools:2.2
        tty: true
        environment:
            - GOPATH=/opt/gopath
            - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
            - FABRIC_LOGGING_SPEC=DEBUG
            - CORE_PEER_ID=cli
            - CORE_PEER_ADDRESS=peer0.org1.aaa.com:7051
            - CORE_PEER_LOCALMSPID=Org1MSP  # 同configtx配置
            - CORE_PEER_TLS_ENABLED=true
            - CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/server.crt
            - CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/server.key
            - CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/ca.crt
            - CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/users/Admin@org1.aaa.com/msp
        working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
        volumes:
            - /var/run/:/host/var/run/
            - ./chaincode/:/opt/gopath/src/github.com/chaincode
            - ./crypto-config:/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/
            - ./channel-artifacts:/opt/gopath/src/github.com/hyperledger/fabric/peer/channel-artifacts
            - ./use_by_cli.sh:/opt/gopath/src/github.com/hyperledger/fabric/peer/use_by_cli.sh
        depends_on:
            - orderer.aaa.com"
echo "$config" >> docker-compose.yaml
for ((i=1; i<=$node_num; i++))
do
    config="            - peer0.org$i.aaa.com"
    echo "$config" >> docker-compose.yaml
done
config="        networks:
            - basic  "
echo "$config" >> docker-compose.yaml
mkdir base
config="version: '2'

services:
  peer-base:
    image: hyperledger/fabric-peer:2.2
    environment:
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=fabric_${node_num}peer_test
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_PROFILE_ENABLED=true
      - CORE_PEER_TLS_CERT_FILE=/etc/hyperledger/fabric/tls/server.crt
      - CORE_PEER_TLS_KEY_FILE=/etc/hyperledger/fabric/tls/server.key
      - CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/fabric/tls/ca.crt
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric/peer
    command: peer node start
"
echo "$config" >  base/peer-base.yaml
echo "version: '2'" > base/dc-base.yaml
config="services:
  orderer.aaa.com:
    container_name: orderer.aaa.com
    image: hyperledger/fabric-orderer:2.2
    environment:
      - ORDERER_GENERAL_LOGLEVEL=debug
      - ORDERER_GENERAL_LISTENADDRESS=0.0.0.0
      - ORDERER_GENERAL_GENESISMETHOD=file
      - ORDERER_GENERAL_GENESISFILE=/var/hyperledger/orderer/orderer.genesis.block
      - ORDERER_GENERAL_LOCALMSPID=OrdererMSP
      - ORDERER_GENERAL_LOCALMSPDIR=/var/hyperledger/orderer/msp
      - ORDERER_GENERAL_TLS_ENABLED=true
      - ORDERER_GENERAL_TLS_PRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_TLS_CERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_TLS_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
      - ORDERER_GENERAL_CLUSTER_CLIENTCERTIFICATE=/var/hyperledger/orderer/tls/server.crt
      - ORDERER_GENERAL_CLUSTER_CLIENTPRIVATEKEY=/var/hyperledger/orderer/tls/server.key
      - ORDERER_GENERAL_CLUSTER_ROOTCAS=[/var/hyperledger/orderer/tls/ca.crt]
    working_dir: /opt/gopath/src/github.com/hyperledger/fabric
    volumes:
    - ../system-genesis-block/genesis.block:/var/hyperledger/orderer/orderer.genesis.block
    - ../crypto-config/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp:/var/hyperledger/orderer/msp
    - ../crypto-config/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/tls/:/var/hyperledger/orderer/tls
    ports:
      - 7050:7050
    command: orderer"
echo "$config" > base/dc-base.yaml
for ((i=1; i<=$node_num; i++))
do
    config="  peer0.org$i.aaa.com:
    container_name: peer0.org$i.aaa.com
    extends:
      file: peer-base.yaml
      service: peer-base
    environment:
      # Peer specific variabes
      - CORE_PEER_ID=peer0.org$i.aaa.com
      - CORE_PEER_ADDRESS=peer0.org$i.aaa.com:$((i * 10 + 7041))
      - CORE_PEER_LISTENADDRESS=0.0.0.0:$((i * 10 + 7041))
      - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org$i.aaa.com:$((i * 10 + 7041))
      - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org$i.aaa.com:$((i * 10 + 7041))      
      - CORE_PEER_LOCALMSPID=Org${i}MSP
      - CORE_PEER_CHAINCODEADDRESS=peer0.org$i.aaa.com:$((i * 10 + 7042))
      - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:$((i * 10 + 7042))
    volumes:
        - /var/run/:/host/var/run/
        - ../crypto-config/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/msp:/etc/hyperledger/fabric/msp
        - ../crypto-config/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls:/etc/hyperledger/fabric/tls
    ports:
      - $((i * 10 + 7041)):$((i * 10 + 7041))
      - $((i * 10 + 7042)):$((i * 10 + 7042)) 
    command: peer node start"
    echo "$config" >> base/dc-base.yaml
done

config="peer channel create -o orderer.aaa.com:7050 -c app-channel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem"
echo "$config" > use_by_cli.sh
for ((i=1; i<=$node_num; i++))
do
config="export CORE_PEER_ADDRESS=peer0.org$i.aaa.com:$((i * 10 + 7041))
export CORE_PEER_LOCALMSPID=Org${i}MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/users/Admin@org$i.aaa.com/msp
peer channel join -b app-channel.block
peer channel update -o orderer.aaa.com:7050 -c app-channel -f ./channel-artifacts/Org${i}MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem
"
echo "$config" >> use_by_cli.sh
done

config="cd /opt/gopath/src/github.com/chaincode/base_test
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GO111MODULE=on
go mod vendor
cd /opt/gopath/src/github.com/hyperledger/fabric/peer 
peer lifecycle chaincode package base.tar.gz --path ../../../chaincode/base_test --lang golang --label base"
echo "$config" >> use_by_cli.sh

for ((i=1; i<=$node_num; i++))
do
config="export CORE_PEER_ADDRESS=peer0.org$i.aaa.com:$((i * 10 + 7041))
export CORE_PEER_LOCALMSPID=Org${i}MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/users/Admin@org$i.aaa.com/msp
peer lifecycle chaincode install base.tar.gz"
echo "$config" >> use_by_cli.sh
done
for ((i=1; i<=$node_num; i++))
do
config="export CORE_PEER_ADDRESS=peer0.org$i.aaa.com:$((i * 10 + 7041))
export CORE_PEER_LOCALMSPID=Org${i}MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/users/Admin@org$i.aaa.com/msp
"
echo "$config" >> use_by_cli.sh
echo 'base_id=$( peer lifecycle chaincode queryinstalled  | grep -o 'base:[a-f0-9]\{64\}')'   >> use_by_cli.sh
echo "peer lifecycle chaincode approveformyorg -o orderer.aaa.com:7050 --ordererTLSHostnameOverride orderer.aaa.com --channelID app-channel --name base --version 1.0 --package-id \$base_id --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem" >> use_by_cli.sh
done
echo "peer lifecycle chaincode checkcommitreadiness --channelID app-channel --name base --version 1.0  --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem --output json" >> use_by_cli.sh

config="peer lifecycle chaincode commit -o orderer.aaa.com:7050 \\
  --channelID app-channel --name base --version 1.0 --sequence 1 --tls \\
  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem \\"
echo "$config" >> use_by_cli.sh
for ((i=1; i<=$node_num; i++))
do
    config="  --peerAddresses peer0.org$i.aaa.com:$((i * 10 + 7041)) \\"
    echo "$config" >> use_by_cli.sh
    if  (( i != node_num  )); then
        config="  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/ca.crt \\"
    else
        config="  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org$i.aaa.com/peers/peer0.org$i.aaa.com/tls/ca.crt  "
    fi
    echo "$config" >> use_by_cli.sh
done