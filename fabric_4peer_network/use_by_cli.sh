# 创建通道
peer channel create -o orderer.aaa.com:7050 -c app-channel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem
export CORE_PEER_ADDRESS=peer0.org1.aaa.com:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/users/Admin@org1.aaa.com/msp
# 加入
peer channel join -b app-channel.block

# 锚节点指定
peer channel update -o orderer.aaa.com:7050 -c app-channel -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem

#org2加入通道,各节点都要加入通道
export CORE_PEER_ADDRESS=peer0.org2.aaa.com:7061
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/users/Admin@org2.aaa.com/msp



peer channel join -b app-channel.block

peer channel update -o orderer.aaa.com:7050 -c app-channel -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem

#org3
export CORE_PEER_ADDRESS=peer0.org3.aaa.com:7071
export CORE_PEER_LOCALMSPID=Org3MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/users/Admin@org3.aaa.com/msp

peer channel join -b app-channel.block

peer channel update -o orderer.aaa.com:7050 -c app-channel -f ./channel-artifacts/Org3MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem
#org4
export CORE_PEER_ADDRESS=peer0.org4.aaa.com:7081
export CORE_PEER_LOCALMSPID=Org4MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.aaa.com/peers/peer0.org4.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.aaa.com/peers/peer0.org4.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.aaa.com/peers/peer0.org4.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.aaa.com/users/Admin@org4.aaa.com/msp

peer channel join -b app-channel.block

peer channel update -o orderer.aaa.com:7050 -c app-channel -f ./channel-artifacts/Org4MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem


#packaging chaincode
cd /opt/gopath/src/github.com/chaincode/base_test
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GO111MODULE=on
go mod vendor
cd /opt/gopath/src/github.com/hyperledger/fabric/peer 
peer lifecycle chaincode package base.tar.gz --path ../../../chaincode/base_test --lang golang --label base




#orgs4 install chaincode
peer lifecycle chaincode install base.tar.gz

#orgs2
export CORE_PEER_ADDRESS=peer0.org2.aaa.com:7061
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/users/Admin@org2.aaa.com/msp
peer lifecycle chaincode install base.tar.gz

#orgs3
export CORE_PEER_ADDRESS=peer0.org3.aaa.com:7071
export CORE_PEER_LOCALMSPID=Org3MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/users/Admin@org3.aaa.com/msp
peer lifecycle chaincode install base.tar.gz

#orgs1
export CORE_PEER_ADDRESS=peer0.org1.aaa.com:7051
export CORE_PEER_LOCALMSPID=Org1MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/users/Admin@org1.aaa.com/msp
peer lifecycle chaincode install base.tar.gz



# every org should run this command to  Approve chaincode
# org1
base_id=$( peer lifecycle chaincode queryinstalled  | grep -o 'base:[a-f0-9]\{64\}')
peer lifecycle chaincode approveformyorg -o orderer.aaa.com:7050 --ordererTLSHostnameOverride orderer.aaa.com --channelID app-channel --name base --version 1.0 --package-id $base_id --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem

#peer lifecycle chaincode approveformyorg --channelID mychannel --name base --version 1.0  --package-id $base_id --sequence 1 --tls true --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem

#org2
export CORE_PEER_ADDRESS=peer0.org2.aaa.com:7061
export CORE_PEER_LOCALMSPID=Org2MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/users/Admin@org2.aaa.com/msp

base_id=$( peer lifecycle chaincode queryinstalled  | grep -o 'base:[a-f0-9]\{64\}')
peer lifecycle chaincode approveformyorg -o orderer.aaa.com:7050 --ordererTLSHostnameOverride orderer.aaa.com --channelID app-channel --name base --version 1.0 --package-id $base_id --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem

#orgs3
export CORE_PEER_ADDRESS=peer0.org3.aaa.com:7071
export CORE_PEER_LOCALMSPID=Org3MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/users/Admin@org3.aaa.com/msp


base_id=$( peer lifecycle chaincode queryinstalled  | grep -o 'base:[a-f0-9]\{64\}')
peer lifecycle chaincode approveformyorg -o orderer.aaa.com:7050 --ordererTLSHostnameOverride orderer.aaa.com --channelID app-channel --name base --version 1.0 --package-id $base_id --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem

#orgs4
export CORE_PEER_ADDRESS=peer0.org4.aaa.com:7081
export CORE_PEER_LOCALMSPID=Org4MSP
export CORE_PEER_TLS_CERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.aaa.com/peers/peer0.org4.aaa.com/tls/server.crt
export CORE_PEER_TLS_KEY_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.aaa.com/peers/peer0.org4.aaa.com/tls/server.key
export CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.aaa.com/peers/peer0.org4.aaa.com/tls/ca.crt
export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.aaa.com/users/Admin@org4.aaa.com/msp

base_id=$( peer lifecycle chaincode queryinstalled  | grep -o 'base:[a-f0-9]\{64\}')
peer lifecycle chaincode approveformyorg -o orderer.aaa.com:7050 --ordererTLSHostnameOverride orderer.aaa.com --channelID app-channel --name base --version 1.0 --package-id $base_id --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem



peer lifecycle chaincode checkcommitreadiness --channelID app-channel --name base --version 1.0  --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem --output json



peer lifecycle chaincode commit -o orderer.aaa.com:7050 \
  --channelID app-channel --name base --version 1.0 --sequence 1 --tls \
  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem \
  --peerAddresses peer0.org1.aaa.com:7051 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/ca.crt \
  --peerAddresses peer0.org2.aaa.com:7061 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.aaa.com/peers/peer0.org2.aaa.com/tls/ca.crt \
  --peerAddresses peer0.org3.aaa.com:7071 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org3.aaa.com/peers/peer0.org3.aaa.com/tls/ca.crt \
  --peerAddresses peer0.org4.aaa.com:7081 \
  --tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org4.aaa.com/peers/peer0.org4.aaa.com/tls/ca.crt

peer chaincode invoke -o orderer.aaa.com:7050 --ordererTLSHostnameOverride orderer.aaa.com --tls true --cafile \
/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem \
-C app-channel -n base --peerAddresses peer0.org1.aaa.com:7051 \
--tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/ca.crt \
-c '{"Args":["Set","3"]}'


peer chaincode query -C app-channel -n base -c '{"Args":["Get"]}'