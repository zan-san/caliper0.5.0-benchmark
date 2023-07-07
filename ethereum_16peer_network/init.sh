node_num=16

for i in `seq 1 $node_num`
do
    #  mkdir node$i
    #  mkdir node$i/keystore
    #  echo password >> node$i/keystore/password
    #  geth --datadir node$i account new --password node$i/keystore/password
     rm -rf node$i/geth
    geth init --datadir node$i genesis.json

done 



