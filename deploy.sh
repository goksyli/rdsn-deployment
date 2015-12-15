#!/bin/bash


set -o errexit
set -o nounset

TARGET_DIR=${TARGET_DIR:-"/home/guoxi/rdsn"}
SOURCE_DIR=${SOURCE_DIR:-"/home/guoxi/cluster-bare"}
METALIST=$(cat ${SOURCE_DIR}/metalist)
HOSTLIST=$(cat ${SOURCE_DIR}/hostlist)
CONFIG=${CONFIG:-"config.ini"}
BINARY=${BINARY:-"simple_kv"}
LIBS=${LIBS:-"libdsn.core.so"}
METACMD="${TARGET_DIR}/${BINARY} ${TARGET_DIR}/${CONFIG} -cargs data-dir=${TARGET_DIR}/meta -app meta"
REPCMD="${TARGET_DIR}/${BINARY}  ${TARGET_DIR}/${CONFIG} -cargs 'meta-ip=${METALIST#*@};data-dir=${TARGET_DIR}/rep' -app replica"


function usage() {
    echo "Option for subcommand 'deploy|start|stop|clean"
    echo " -s|--source <dir>      local source directory for deployment"
    echo " -t|--target <dir>    remote target directory for deployment"
    echo " -b|--binary <program> program for deployment"
    echo " all options are mandatory"
}









function add-file() {

    echo "deploy directory ${SOURCE_DIR} to ${TARGET_DIR} at $1"

    ssh $1 "mkdir -p ${TARGET_DIR}/meta ${TARGET_DIR}/rep"

    scp ${SOURCE_DIR}/${BINARY}  ${SOURCE_DIR}/${CONFIG} ${SOURCE_DIR}/${LIBS} "${1}:${TARGET_DIR}"

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

CMD=$1
shift
while [[ $# > 0 ]];do
    key="$1"
    case $key in
        -s|--source)
            SOURCE_DIR=$2
            shift 2
            ;;
        -t|--target)
            TARGET_DIR=$2
            shift 2
            ;;
        -b|--binary)
            BINARY=$2
            shift 2
            ;;
        *)
            echo "ERROR: unknown option $key"
            echo
            usage
  #          exit -1
            ;;
    esac
done


case $CMD in
    start)
        start_rdsn
        ;;
    stop)
        stop_rdsn
        ;;
    deploy)
        deploy_rdsn
        ;;
    clean)
        clean_rdsn
        ;;
    *)
        echo "Bug shouldn't come here"
        echo
        ;;
esac





