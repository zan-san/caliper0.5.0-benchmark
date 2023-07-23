#!/bin/bash
SHELL_FOLDER=$(cd $(dirname $0);pwd)

LOG_ERROR() {
    content=${1}
    echo -e "\033[31m[ERROR] ${content}\033[0m"
}

LOG_INFO() {
    content=${1}
    echo -e "\033[32m[INFO] ${content}\033[0m"
}

fisco_bcos=${SHELL_FOLDER}/../fisco-bcos
cd ${SHELL_FOLDER}
node=$(basename ${SHELL_FOLDER})
node_pid=$(docker ps |grep ${SHELL_FOLDER//\//} | grep -v grep|awk '{print $1}')
if [ -n "${node_pid}" ];then
    echo " ${node} is running, container id is $node_pid."
    exit 0
else
    docker run -d --rm --name ${SHELL_FOLDER//\//} -v ${SHELL_FOLDER}:/data --network=host -w=/data fiscoorg/fiscobcos:v2.9.1 -c config.ini
    sleep 1.5
fi
try_times=4
i=0
while [ $i -lt ${try_times} ]
do
    node_pid=$(docker ps |grep ${SHELL_FOLDER//\//} | grep -v grep|awk '{print $1}')
    success_flag=success
    if [[ -n "${node_pid}" && -n "${success_flag}" ]];then
        echo -e "\033[32m ${node} start successfully\033[0m"
        exit 0
    fi
    sleep 0.5
    ((i=i+1))
done
echo -e "\033[31m  Exceed waiting time. Please try again to start ${node} \033[0m"
tail -n20 $(docker inspect --format='{{.LogPath}}' ${SHELL_FOLDER//\//})
exit 1
