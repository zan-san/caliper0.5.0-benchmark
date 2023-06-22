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

for ORG in {1..16}
do
  P0PORT=$((7041 + ORG * 10))
  CAPORT=8000
  PEERPEM="crypto-config/peerOrganizations/org${ORG}.aaa.com/tlsca/tlsca.org${ORG}.aaa.com-cert.pem"
  CAPEM="crypto-config/peerOrganizations/org${ORG}.aaa.com/ca/ca.org${ORG}.aaa.com-cert.pem"
  JSON_FILE="crypto-config/peerOrganizations/org${ORG}.aaa.com/connection-org${ORG}.json"
  YAML_FILE="crypto-config/peerOrganizations/org${ORG}.aaa.com/connection-org${ORG}.yaml"

  echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > $JSON_FILE
  echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > $YAML_FILE

  echo "Generated JSON file: $JSON_FILE"
  echo "Generated YAML file: $YAML_FILE"
done