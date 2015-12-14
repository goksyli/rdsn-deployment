#!/bin/bash

PROGRAM=/home/rdsn/dsn.replication.simple_kv
CONFIG=/home/rdsn/config.ini
DATA=/home/rdsn/data/

if [ "x$NAME" = "x" ];then
    echo "NAME is empty"
    exit 137
fi

if [ "x$NUM" = "x" ];then
    echo "NUM is empty"
    exit 137
fi

#echo $NAME

case $NAME in
    META*)

        HOST=`printenv ${NAME}_${NUM}_SERVICE_HOST`
        PORT=`printenv ${NAME}_${NUM}_SERVICE_PORT`
        ARGS="-cargs explicit-host-address=${HOST};data-dir=${DATA} -app meta"
        ;;
    REPLICA*)

        HOST=`printenv ${NAME}_${NUM}_SERVICE_HOST`
        PORT=`printenv ${NAME}_${NUM}_SERVICE_PORT`
        META_HOST=`printenv META_1_SERVICE_HOST`
        ARGS="-cargs localhost=${META_HOST};explicit-host-address=${HOST};data-dir=${DATA} -app replica"
        ;;
    CLIENT*)
        HOST=`printenv ${NAME}_${NUM}_SERVICE_HOST`
        PORT=`printenv ${NAME}_${NUM}_SERVICE_PORT`
        META_HOST=`printenv META_1_SERVICE_HOST`
        ARGS="-cargs localhost=${META_HOST};explicit-host-address=${HOST};data-dir=${DATA} -app client"
        ;;
    *)
        echo "Not supporting type of service"
        exit 137
        ;;
esac


echo ${PROGRAM} ${CONFIG} ${ARGS} > command.log

${PROGRAM} ${CONFIG} ${ARGS}
