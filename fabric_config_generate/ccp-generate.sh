#!/bin/bash

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

ORG=1
P0PORT=7051
CAPORT=8000
PEERPEM=crypto-config/peerOrganizations/org1.aaa.com/tlsca/tlsca.org1.aaa.com-cert.pem
CAPEM=crypto-config/peerOrganizations/org1.aaa.com/ca/ca.org1.aaa.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org1.aaa.com/connection-org1.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org1.aaa.com/connection-org1.yaml

ORG=2
P0PORT=7061
CAPORT=8000
PEERPEM=crypto-config/peerOrganizations/org2.aaa.com/tlsca/tlsca.org2.aaa.com-cert.pem
CAPEM=crypto-config/peerOrganizations/org2.aaa.com/ca/ca.org2.aaa.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org2.aaa.com/connection-org2.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org2.aaa.com/connection-org2.yaml

ORG=3
P0PORT=7071
CAPORT=8000
PEERPEM=crypto-config/peerOrganizations/org3.aaa.com/tlsca/tlsca.org3.aaa.com-cert.pem
CAPEM=crypto-config/peerOrganizations/org3.aaa.com/ca/ca.org3.aaa.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org3.aaa.com/connection-org3.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org3.aaa.com/connection-org3.yaml

ORG=4
P0PORT=7081
CAPORT=8000
PEERPEM=crypto-config/peerOrganizations/org4.aaa.com/tlsca/tlsca.org4.aaa.com-cert.pem
CAPEM=crypto-config/peerOrganizations/org4.aaa.com/ca/ca.org4.aaa.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org4.aaa.com/connection-org4.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > crypto-config/peerOrganizations/org4.aaa.com/connection-org4.yaml
