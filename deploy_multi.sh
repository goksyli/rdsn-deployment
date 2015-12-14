#!/bin/bash



METALIST=$(cat metalist)
HOSTLIST=$(cat hostlist)


TARGET_DIR="/home/guoxi/rdsn"
SOURCE_DIR="/home/guoxi/cluster-bare"
CONFIG="config.ini"
BINARY="simple_kv"
LIBS="libdsn.core.so"
METACMD="${TARGET_DIR}/${BINARY} ${TARGET_DIR}/${CONFIG} -cargs data-dir=/home/guoxi/rdsn/meta -app meta"
REPCMD="${TARGET_DIR}/${BINARY}  ${TARGET_DIR}/${CONFIG} -cargs 'meta-ip="${METALIST#*@}";data-dir=/home/guoxi/rdsn/rep' -app replica"

function add-file() {

    ssh $1 "mkdir -p ${TARGET_DIR}/meta ${TARGET_DIR}/rep"

    scp ${SOURCE_DIR}/${CONFIG} ${SOURCE_DIR}/${BINARY} ${SOURCE_DIR}/${LIBS} "${1}:${TARGET_DIR}"

}


function up-meta() {

    echo "starting meta at $1"

    ssh $1 'nohup sh -c "( ( export LD_LIBRARY_PATH='${TARGET_DIR}';'${METACMD}'> foo.out 2>foo.err < /dev/null)&)"'

}
function up-rep() {

    echo "starting rep at $1"

    ssh $1 'nohup sh -c "( ( export LD_LIBRARY_PATH='${TARGET_DIR}';'${REPCMD}'> foo.out 2>foo.err < /dev/null)&)"'

}

function down-binary(){
    echo "stopping at $1"
    ssh $1 'pgrep '${BINARY}' | xargs kill -9'
}

function clean-up(){
    echo "cleaning at $1"
    ssh $1 'rm -rf '${TARGET_DIR}'/'
}




function deploy_rdsn(){
   
    for i in $METALIST;do
        add-file $i
    done


    for i in $HOSTLIST;do
        add-file $i
    done
}

function start_rdsn(){


    for i in $METALIST;do
        up-meta $i
    done


    for i in $HOSTLIST;do
        up-rep $i
    done
}


function stop_rdsn(){


    for i in $METALIST;do
        down-binary $i
    done


    for i in $HOSTLIST;do
        down-binary $i
    done
}

function clean_rdsn(){

    for i in $METALIST;do
        clean-up $i
    done


    for i in $HOSTLIST;do
        clean-up $i
    done
}


case $1 in
    start*)
        start_rdsn
        ;;
    stop*)
        stop_rdsn
        ;;
    deploy*)
        deploy_rdsn
        ;;
    clean*)
        clean_rdsn
        ;;
esac





