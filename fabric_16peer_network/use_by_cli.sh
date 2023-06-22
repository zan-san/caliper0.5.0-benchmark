


num_iterations=16
set_peer_env() {
    local org_number="$1"
    local port=$((7041 + org_number * 10))

    export CORE_PEER_ADDRESS="peer0.org${org_number}.aaa.com:${port}"
    export CORE_PEER_LOCALMSPID="Org${org_number}MSP"
    export CORE_PEER_TLS_CERT_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${org_number}.aaa.com/peers/peer0.org${org_number}.aaa.com/tls/server.crt"
    export CORE_PEER_TLS_KEY_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${org_number}.aaa.com/peers/peer0.org${org_number}.aaa.com/tls/server.key"
    export CORE_PEER_TLS_ROOTCERT_FILE="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${org_number}.aaa.com/peers/peer0.org${org_number}.aaa.com/tls/ca.crt"
    export CORE_PEER_MSPCONFIGPATH="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${org_number}.aaa.com/users/Admin@org${org_number}.aaa.com/msp"
}


# 创建通道
peer channel create -o orderer.aaa.com:7050 -c app-channel -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem

# 循环执行 16 次
for ((i=1; i<=num_iterations; i++))
do
    set_peer_env "$i"
    peer channel join -b app-channel.block
    peer channel update -o orderer.aaa.com:7050 -c app-channel -f ./channel-artifacts/Org${i}MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem
done

#packaging chaincode
cd /opt/gopath/src/github.com/chaincode/base_test
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GO111MODULE=on
go mod vendor
cd /opt/gopath/src/github.com/hyperledger/fabric/peer 
peer lifecycle chaincode package base.tar.gz --path ../../../chaincode/base_test --lang golang --label base



# 循环执行脚本函数
for ((i=1; i<=num_iterations; i++))
do
    set_peer_env "$i"
    peer lifecycle chaincode install base.tar.gz
done


# every org should run this command to  Approve chaincode

for ((i=1; i<=num_iterations; i++))
do
    set_peer_env "$i"
    base_id=$( peer lifecycle chaincode queryinstalled  | grep -o 'base:[a-f0-9]\{64\}')
    peer lifecycle chaincode approveformyorg \
      -o orderer.aaa.com:7050 \
      --ordererTLSHostnameOverride orderer.aaa.com \
      --channelID app-channel \
      --name base \
      --version 1.0 \
      --package-id $base_id \
      --sequence 1 \
      --tls \
      --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem

done

peer lifecycle chaincode checkcommitreadiness --channelID app-channel --name base --version 1.0  --sequence 1 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem --output json


peer_addresses=""
tls_root_cert_files=""

for ((i=1; i<=num_iterations; i++))
do
  port=$((7041 + i * 10))
  peer_address="peer0.org${i}.aaa.com:${port}"
  tls_root_cert_file="/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org${i}.aaa.com/peers/peer0.org${i}.aaa.com/tls/ca.crt"
  
  peer_addresses+=" --peerAddresses ${peer_address}"
  peer_addresses+=" --tlsRootCertFiles ${tls_root_cert_file}"
done

peer lifecycle chaincode commit \
  -o orderer.aaa.com:7050 \
  --channelID app-channel \
  --name base \
  --version 1.0 \
  --sequence 1 \
  --tls \
  --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem \
  ${peer_addresses} 



peer chaincode invoke -o orderer.aaa.com:7050 --ordererTLSHostnameOverride orderer.aaa.com --tls true --cafile \
/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/aaa.com/orderers/orderer.aaa.com/msp/tlscacerts/tlsca.aaa.com-cert.pem \
-C app-channel -n base --peerAddresses peer0.org1.aaa.com:7051 \
--tlsRootCertFiles /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.aaa.com/peers/peer0.org1.aaa.com/tls/ca.crt \
-c '{"Args":["Set","3"]}'


peer chaincode query -C app-channel -n base -c '{"Args":["Get"]}'