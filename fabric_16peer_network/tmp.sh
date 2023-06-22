#!/bin/bash

for i in {3..16}; do
    port1=$((7041 + i * 10))
    port2=$((7042 + i * 10))
    
    echo "peer0.org${i}.aaa.com:"
    echo "  container_name: peer0.org${i}.aaa.com"
    echo "  extends:"
    echo "    file: peer-base.yaml"
    echo "    service: peer-base"
    echo "  environment:"
    echo "    # Peer specific variables"
    echo "    - CORE_PEER_ID=peer0.org${i}.aaa.com"
    echo "    - CORE_PEER_ADDRESS=peer0.org${i}.aaa.com:${port1}"
    echo "    - CORE_PEER_LISTENADDRESS=0.0.0.0:${port1}"
    echo "    - CORE_PEER_GOSSIP_EXTERNALENDPOINT=peer0.org${i}.aaa.com:${port1}"
    echo "    - CORE_PEER_GOSSIP_BOOTSTRAP=peer0.org${i}.aaa.com:${port1}"
    echo "    - CORE_PEER_LOCALMSPID=Org${i}MSP"
    echo "    - CORE_PEER_CHAINCODEADDRESS=peer0.org${i}.aaa.com:${port2}"
    echo "    - CORE_PEER_CHAINCODELISTENADDRESS=0.0.0.0:${port2}"
    echo "  volumes:"
    echo "    - /var/run/:/host/var/run/"
    echo "    - ../crypto-config/peerOrganizations/org${i}.aaa.com/peers/peer0.org${i}.aaa.com/msp:/etc/hyperledger/fabric/msp"
    echo "    - ../crypto-config/peerOrganizations/org${i}.aaa.com/peers/peer0.org${i}.aaa.com/tls:/etc/hyperledger/fabric/tls"
    echo "  ports:"
    echo "    - ${port1}:${port1}"
    echo "    - ${port2}:${port2}"
    echo "  command: peer node start"
    echo
done

