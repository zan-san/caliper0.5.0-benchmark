#!/bin/bash

# Define the common IP
ip="127.0.0.1"

# Define the starting port numbers
rpcPort=8545
channelPort=20200

# Define the number of configurations to generate
numConfigs=16

# Loop to generate configurations
for ((i=0; i<numConfigs; i++))
do
    config="{\n    \"ip\": \"$ip\",\n    \"rpcPort\": \"$rpcPort\",\n    \"channelPort\": \"$channelPort\"\n},"
    echo -e "$config"

    # Increment the port numbers
    ((rpcPort++))
    ((channelPort++))
done
