#!/bin/bash



METALIST=$(cat metalist)
HOSTLIST=$(cat hostlist)

#PROGRAM=~/rdsn/simple_kv
#CONFIG=~/rdsn/config.ini

METACMD="~/rdsn/simple_kv ~/rdsn/config.ini -cargs data-dir=/home/guoxi/rdsn/meta -app meta"
REPCMD="~/rdsn/simple_kv ~/rdsn/config.ini -cargs 'meta-ip="${METALIST#*@}";data-dir=/home/guoxi/rdsn/rep' -app replica"


function add-file() {

    ssh $1 "mkdir -p ~/rdsn/meta ~/rdsn/rep"

    scp config.ini simple_kv libdsn.core.so "${1}:~/rdsn"

}


function up-meta() {

    ssh $1 'nohup sh -c "( ( export LD_LIBRARY_PATH=/home/guoxi/rdsn;'${METACMD}'> foo.out 2>foo.err < /dev/null)&)"'

}
function up-rep() {

    ssh $1 'nohup sh -c "( ( export LD_LIBRARY_PATH=/home/guoxi/rdsn;'${REPCMD}'> foo.out 2>foo.err < /dev/null)&)"'

}





for i in $METALIST;do
        add-file $i

        up-meta $i
done


for i in $HOSTLIST;do
    add-file $i

    up-rep $i

done
