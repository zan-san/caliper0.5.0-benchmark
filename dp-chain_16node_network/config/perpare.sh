#!/bin/bash
cp /dpchain/dper/client/auto/dper_dper1/dperClient  /data/dperClient
cp /dpchain/dper/client/auto/dper_dper1/daemon  /data/daemon 
cp /dpchain/dper/client/auto/dper_dper1/daemonClose  /data/daemonClose
cd /data
sleep 5s
./dperClient -mode=multi_http
